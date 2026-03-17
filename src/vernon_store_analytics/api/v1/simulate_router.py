"""
API routes untuk simulasi deteksi — test shoplifting detection tanpa CCTV asli.
Hanya tersedia di mode development.
"""

import random
import uuid
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.config import get_settings
from ...core.database import get_db
from ...models.db.detection_log import DetectionLog
from ...models.db.mood_log import MoodLog
from ...models.db.shoplifting_alert import ShopliftingAlert
from ...models.db.visit import Visit
from ...models.db.visitor import Visitor
from ...services.stream.shoplifting_detector import ShopliftingDetector
from ...services.stream.stream_manager import StreamManager
from .dependencies import get_current_user

settings = get_settings()
router = APIRouter(prefix="/simulate", tags=["simulate"])

MOODS = ["happy", "neutral", "sad", "angry", "surprise", "fear", "disgust"]


@router.post("/detection")
async def simulate_detection(
    store_id: int = Query(...),
    camera_id: int = Query(...),
    zone: str = Query("floor", description="Zone: entry, floor, cashier, exit"),
    person_uid: str | None = Query(None, description="Person UID (auto-generate jika kosong)"),
    gender: str = Query("male", description="male/female"),
    age: int = Query(30),
    mood: str = Query("neutral", description="happy, neutral, sad, angry, surprise, fear, disgust"),
    db: AsyncSession = Depends(get_db),
    _: dict = Depends(get_current_user),
):
    """
    Simulasi satu deteksi — seperti stream processor mendeteksi seseorang di frame.
    Berguna untuk test shoplifting detection tanpa CCTV.
    """
    if not person_uid:
        person_uid = f"SIM_{uuid.uuid4().hex[:12]}"

    now = datetime.now(timezone.utc)

    # Upsert visitor
    from sqlalchemy import select
    result = await db.execute(select(Visitor).where(Visitor.person_uid == person_uid))
    visitor = result.scalar_one_or_none()

    if not visitor:
        from ...services.stream.frame_analyzer import _classify_age_group
        visitor = Visitor(
            store_id=store_id,
            person_uid=person_uid,
            gender=gender,
            age_estimate=age,
            age_group=_classify_age_group(age),
            first_seen_at=now,
            last_seen_at=now,
            total_visits=1,
        )
        db.add(visitor)
        await db.flush()
    else:
        visitor.last_seen_at = now

    # Upsert visit
    result = await db.execute(
        select(Visit).where(Visit.visitor_id == visitor.id, Visit.exit_at.is_(None))
    )
    visit = result.scalar_one_or_none()
    if not visit:
        visit = Visit(visitor_id=visitor.id, camera_id=camera_id)
        db.add(visit)
        await db.flush()

    # Mood log
    mood_conf = round(random.uniform(0.5, 0.95), 3)
    db.add(MoodLog(visit_id=visit.id, zone=zone, mood=mood, confidence=mood_conf))
    db.add(DetectionLog(
        visit_id=visit.id, camera_id=camera_id, zone=zone,
        gender=gender, age_estimate=age, mood=mood, mood_confidence=mood_conf,
    ))

    # Update shoplifting detector
    manager = StreamManager.get_instance()
    detector = manager.shoplifting_detector
    detector.update_profile(
        person_uid=person_uid,
        visit_id=visit.id,
        zone=zone,
        mood=mood,
        mood_confidence=mood_conf,
    )

    # Evaluate
    score = detector.evaluate(person_uid)
    alert_created = False

    if score and score.is_alert:
        alert = ShopliftingAlert(
            visit_id=visit.id,
            camera_id=camera_id,
            confidence=score.confidence,
            notified=True,
        )
        db.add(alert)
        alert_created = True

    await db.commit()

    return {
        "success": True,
        "detection": {
            "person_uid": person_uid,
            "visitor_id": visitor.id,
            "visit_id": visit.id,
            "zone": zone,
            "mood": mood,
            "mood_confidence": mood_conf,
        },
        "shoplifting_score": score.to_dict() if score else None,
        "alert_created": alert_created,
    }


@router.post("/shoplifting-scenario")
async def simulate_shoplifting_scenario(
    store_id: int = Query(...),
    camera_id_entry: int = Query(..., description="Camera ID zona entry"),
    camera_id_floor: int = Query(..., description="Camera ID zona floor"),
    camera_id_exit: int = Query(..., description="Camera ID zona exit"),
    db: AsyncSession = Depends(get_db),
    _: dict = Depends(get_current_user),
):
    """
    Simulasi skenario shoplifting lengkap:
    1. Masuk store (mood nervous)
    2. Lama di floor area (mood fear/angry, mondar-mandir)
    3. Tidak ke kasir
    4. Langsung keluar

    Akan trigger shoplifting alert jika rules terpenuhi.
    """
    person_uid = f"SIM_THEFT_{uuid.uuid4().hex[:8]}"
    now = datetime.now(timezone.utc)
    manager = StreamManager.get_instance()
    detector = manager.shoplifting_detector

    from sqlalchemy import select
    from ...services.stream.frame_analyzer import _classify_age_group

    # Create visitor
    visitor = Visitor(
        store_id=store_id,
        person_uid=person_uid,
        gender=random.choice(["male", "female"]),
        age_estimate=random.randint(18, 45),
        age_group=_classify_age_group(random.randint(18, 45)),
        first_seen_at=now - timedelta(minutes=20),
        last_seen_at=now,
        total_visits=1,
    )
    db.add(visitor)
    await db.flush()

    visit = Visit(
        visitor_id=visitor.id,
        camera_id=camera_id_entry,
        entry_at=now - timedelta(minutes=20),
    )
    db.add(visit)
    await db.flush()

    steps = []
    alerts = []

    # Step 1: Entry — mood nervous (fear)
    step_time = now - timedelta(minutes=20)
    mood = "fear"
    conf = round(random.uniform(0.6, 0.9), 3)
    db.add(MoodLog(visit_id=visit.id, zone="entry", mood=mood, confidence=conf, timestamp=step_time))
    db.add(DetectionLog(visit_id=visit.id, camera_id=camera_id_entry, zone="entry",
                        gender=visitor.gender, age_estimate=visitor.age_estimate,
                        mood=mood, mood_confidence=conf, timestamp=step_time))
    detector.update_profile(person_uid, visit.id, "entry", mood, conf)
    # Override first_seen
    profile = detector.get_profile(person_uid)
    if profile:
        profile.first_seen = step_time
    steps.append({"time": step_time.isoformat(), "zone": "entry", "mood": mood})

    # Step 2-7: Floor area — mondar-mandir, mood gelisah
    nervous_moods = ["fear", "angry", "disgust", "fear", "angry", "fear"]
    for i, m in enumerate(nervous_moods):
        step_time = now - timedelta(minutes=18 - i * 2)
        conf = round(random.uniform(0.55, 0.85), 3)
        db.add(MoodLog(visit_id=visit.id, zone="floor", mood=m, confidence=conf, timestamp=step_time))
        db.add(DetectionLog(visit_id=visit.id, camera_id=camera_id_floor, zone="floor",
                            gender=visitor.gender, age_estimate=visitor.age_estimate,
                            mood=m, mood_confidence=conf, timestamp=step_time))
        detector.update_profile(person_uid, visit.id, "floor", m, conf)
        steps.append({"time": step_time.isoformat(), "zone": "floor", "mood": m})

    # Step 8: Tiba-tiba ke entry lagi (mondar-mandir)
    step_time = now - timedelta(minutes=5)
    mood = "angry"
    conf = round(random.uniform(0.6, 0.8), 3)
    db.add(MoodLog(visit_id=visit.id, zone="entry", mood=mood, confidence=conf, timestamp=step_time))
    detector.update_profile(person_uid, visit.id, "entry", mood, conf)
    steps.append({"time": step_time.isoformat(), "zone": "entry", "mood": mood})

    # Step 9: Balik ke floor
    step_time = now - timedelta(minutes=3)
    mood = "fear"
    conf = round(random.uniform(0.7, 0.9), 3)
    db.add(MoodLog(visit_id=visit.id, zone="floor", mood=mood, confidence=conf, timestamp=step_time))
    detector.update_profile(person_uid, visit.id, "floor", mood, conf)
    steps.append({"time": step_time.isoformat(), "zone": "floor", "mood": mood})

    # Step 10: Exit tanpa ke kasir
    step_time = now
    mood = "fear"
    conf = round(random.uniform(0.7, 0.9), 3)
    db.add(MoodLog(visit_id=visit.id, zone="exit", mood=mood, confidence=conf, timestamp=step_time))
    db.add(DetectionLog(visit_id=visit.id, camera_id=camera_id_exit, zone="exit",
                        gender=visitor.gender, age_estimate=visitor.age_estimate,
                        mood=mood, mood_confidence=conf, timestamp=step_time))
    detector.update_profile(person_uid, visit.id, "exit", mood, conf)
    steps.append({"time": step_time.isoformat(), "zone": "exit", "mood": mood})

    # Update visit exit
    visit.exit_at = now
    visit.dwell_seconds = 1200  # 20 min

    # Final evaluation
    score = detector.evaluate(person_uid)
    if score and score.is_alert:
        alert = ShopliftingAlert(
            visit_id=visit.id,
            camera_id=camera_id_floor,
            confidence=score.confidence,
            notified=True,
        )
        db.add(alert)
        await db.flush()
        alerts.append({
            "alert_id": alert.id,
            "confidence": round(score.confidence, 3),
            "reasons": score.reasons,
        })

    await db.commit()

    return {
        "success": True,
        "scenario": "shoplifting_suspect",
        "person_uid": person_uid,
        "visitor_id": visitor.id,
        "visit_id": visit.id,
        "steps": steps,
        "final_score": score.to_dict() if score else None,
        "alerts_created": alerts,
        "profile": {
            "total_dwell_seconds": 1200,
            "zones_visited": [s["zone"] for s in steps],
            "visited_cashier": False,
            "visited_exit": True,
            "nervous_ratio": round(profile.nervous_ratio, 3) if profile else None,
        },
    }
