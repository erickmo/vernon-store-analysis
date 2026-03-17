"""
Seed script — populate database dengan data demo realistis.
Menghasilkan: store, cameras, visitors, visits, mood logs, detection logs, traffic snapshots.

Usage:
    python -m scripts.seed          # seed default (150 visitors, 24 jam)
    python -m scripts.seed --reset  # hapus semua data lalu seed ulang
    python -m scripts.seed --visitors 300 --days 7
"""

import argparse
import asyncio
import random
import sys
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path

# Add project root to path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from sqlalchemy import delete, text
from sqlalchemy.ext.asyncio import AsyncSession

from src.vernon_store_analytics.core.config import get_settings
from src.vernon_store_analytics.core.database import AsyncSessionFactory, engine
from src.vernon_store_analytics.core.security import hash_password
from src.vernon_store_analytics.models.db.camera import Camera
from src.vernon_store_analytics.models.db.detection_log import DetectionLog
from src.vernon_store_analytics.models.db.mood_log import MoodLog
from src.vernon_store_analytics.models.db.shoplifting_alert import ShopliftingAlert
from src.vernon_store_analytics.models.db.store import Store
from src.vernon_store_analytics.models.db.traffic_snapshot import TrafficSnapshot
from src.vernon_store_analytics.models.db.user import User
from src.vernon_store_analytics.models.db.visit import Visit
from src.vernon_store_analytics.models.db.visitor import Visitor

settings = get_settings()

# ── Constants ─────────────────────────────────────────────────
GENDERS = ["male", "female"]
GENDER_WEIGHTS = [0.55, 0.45]

AGE_GROUPS = {
    "child": (5, 12),
    "teenager": (13, 17),
    "young_adult": (18, 25),
    "adult": (26, 39),
    "middle_aged": (40, 59),
    "senior": (60, 80),
}
AGE_GROUP_WEIGHTS = [0.05, 0.10, 0.25, 0.30, 0.20, 0.10]

MOODS = ["happy", "neutral", "sad", "angry", "surprise", "fear", "disgust"]

# Mood distribution per zone (realistic retail)
MOOD_WEIGHTS = {
    "entry": [0.35, 0.40, 0.08, 0.02, 0.10, 0.03, 0.02],      # mostly happy/neutral saat masuk
    "floor": [0.25, 0.45, 0.10, 0.03, 0.12, 0.03, 0.02],       # lebih neutral saat browsing
    "cashier": [0.30, 0.35, 0.10, 0.08, 0.05, 0.05, 0.07],     # mixed saat bayar
    "exit": [0.40, 0.35, 0.10, 0.03, 0.05, 0.02, 0.05],        # lebih happy setelah belanja
}

ZONES = ["entry", "floor", "cashier", "exit"]

# Dwell time distribution (seconds) — realistic retail
DWELL_RANGES = [
    (30, 60, 0.10),       # quick visit < 1 min
    (60, 300, 0.20),      # 1-5 min browsing
    (300, 900, 0.30),     # 5-15 min shopping
    (900, 1800, 0.25),    # 15-30 min proper shopping
    (1800, 3600, 0.10),   # 30-60 min long visit
    (3600, 7200, 0.05),   # > 60 min extended
]


def pick_age_group() -> tuple[str, int]:
    """Random age group dan age estimate."""
    group = random.choices(list(AGE_GROUPS.keys()), weights=AGE_GROUP_WEIGHTS, k=1)[0]
    age_min, age_max = AGE_GROUPS[group]
    age = random.randint(age_min, age_max)
    return group, age


def pick_mood(zone: str) -> tuple[str, float]:
    """Random mood berdasarkan zone dengan confidence."""
    weights = MOOD_WEIGHTS.get(zone, MOOD_WEIGHTS["floor"])
    mood = random.choices(MOODS, weights=weights, k=1)[0]
    confidence = round(random.uniform(0.5, 0.98), 3)
    return mood, confidence


def pick_dwell() -> int:
    """Random dwell time (seconds) berdasarkan distribusi realistis."""
    ranges_only = [(lo, hi) for lo, hi, _ in DWELL_RANGES]
    weights = [w for _, _, w in DWELL_RANGES]
    lo, hi = random.choices(ranges_only, weights=weights, k=1)[0]
    return random.randint(lo, hi)


def random_time_in_range(start: datetime, end: datetime) -> datetime:
    """Random datetime antara start dan end, bias ke jam operasional (09-21)."""
    while True:
        delta = (end - start).total_seconds()
        offset = random.uniform(0, delta)
        dt = start + timedelta(seconds=offset)
        hour = dt.hour
        # Bias ke jam operasional: 70% chance jam 09-21, 30% chance lainnya
        if 9 <= hour <= 21 or random.random() < 0.15:
            return dt


async def reset_data(db: AsyncSession) -> None:
    """Hapus semua data dari semua tabel."""
    print("🗑  Menghapus semua data...")
    await db.execute(delete(DetectionLog))
    await db.execute(delete(MoodLog))
    await db.execute(delete(ShopliftingAlert))
    await db.execute(delete(TrafficSnapshot))
    await db.execute(delete(Visit))
    await db.execute(delete(Visitor))
    await db.execute(delete(Camera))
    await db.execute(delete(Store))
    await db.execute(delete(User))
    await db.commit()
    print("   Done.")


async def seed_users(db: AsyncSession) -> User:
    """Seed admin user."""
    from sqlalchemy import select
    result = await db.execute(select(User).where(User.email == "admin@vernon.com"))
    existing = result.scalar_one_or_none()
    if existing:
        print(f"   User admin@vernon.com sudah ada (id={existing.id})")
        return existing

    user = User(
        email="admin@vernon.com",
        full_name="Admin Vernon",
        hashed_password=hash_password("adminpass123!"),
        role="admin",
    )
    db.add(user)
    await db.flush()
    print(f"   User: admin@vernon.com / adminpass123! (id={user.id})")
    return user


async def seed_store_and_cameras(db: AsyncSession) -> tuple[Store, list[Camera]]:
    """Seed 1 store dengan 4 cameras (satu per zone)."""
    store = Store(
        name="Vernon Flagship Store",
        location="Jl. Sudirman No. 123, Jakarta Selatan",
        timezone="Asia/Jakarta",
        description="Toko flagship Vernon — fashion & lifestyle retail",
    )
    db.add(store)
    await db.flush()
    print(f"   Store: {store.name} (id={store.id})")

    camera_configs = [
        ("CAM-ENTRY", "rtsp://192.168.1.101:554/stream", "entry", "Kamera pintu masuk utama"),
        ("CAM-FLOOR", "rtsp://192.168.1.102:554/stream", "floor", "Kamera area display utama"),
        ("CAM-CASHIER", "rtsp://192.168.1.103:554/stream", "cashier", "Kamera area kasir"),
        ("CAM-EXIT", "rtsp://192.168.1.104:554/stream", "exit", "Kamera pintu keluar"),
    ]

    cameras = []
    for name, url, zone, desc in camera_configs:
        cam = Camera(
            store_id=store.id,
            name=name,
            stream_url=url,
            location_zone=zone,
            description=desc,
        )
        db.add(cam)
        cameras.append(cam)

    await db.flush()
    for c in cameras:
        await db.refresh(c)
        print(f"   Camera: {c.name} [{c.location_zone}] (id={c.id})")

    return store, cameras


async def seed_visitors_and_visits(
    db: AsyncSession,
    store: Store,
    cameras: list[Camera],
    num_visitors: int,
    days: int,
) -> None:
    """Seed visitors, visits, mood logs, dan detection logs."""
    now = datetime.now(timezone.utc)
    period_start = now - timedelta(days=days)

    # Map zone -> camera
    zone_camera = {c.location_zone: c for c in cameras}

    print(f"   Generating {num_visitors} visitors over {days} days...")

    all_visitors = []
    all_visits = []
    all_mood_logs = []
    all_detection_logs = []

    for i in range(num_visitors):
        gender = random.choices(GENDERS, weights=GENDER_WEIGHTS, k=1)[0]
        age_group, age = pick_age_group()
        person_uid = f"VST_{uuid.uuid4().hex[:12]}"

        entry_time = random_time_in_range(period_start, now)
        dwell_secs = pick_dwell()
        exit_time = entry_time + timedelta(seconds=dwell_secs)
        if exit_time > now:
            exit_time = now
            dwell_secs = int((exit_time - entry_time).total_seconds())

        visitor = Visitor(
            store_id=store.id,
            person_uid=person_uid,
            gender=gender,
            age_estimate=age,
            age_group=age_group,
            first_seen_at=entry_time,
            last_seen_at=exit_time,
            total_visits=random.randint(1, 5),
        )
        db.add(visitor)
        all_visitors.append(visitor)

    # Flush to get visitor IDs
    await db.flush()

    for visitor in all_visitors:
        entry_time = visitor.first_seen_at
        dwell_secs = int((visitor.last_seen_at - visitor.first_seen_at).total_seconds())
        exit_time = visitor.last_seen_at

        # Pick entry camera
        entry_cam = zone_camera.get("entry", cameras[0])

        visit = Visit(
            visitor_id=visitor.id,
            camera_id=entry_cam.id,
            entry_at=entry_time,
            exit_at=exit_time,
            dwell_seconds=dwell_secs,
        )
        db.add(visit)
        all_visits.append((visit, visitor, entry_time, exit_time, dwell_secs))

    await db.flush()

    # Generate mood logs & detection logs per visit
    for visit_tuple in all_visits:
        visit, visitor, entry_time, exit_time, dwell_secs = visit_tuple

        # Entry mood
        mood, conf = pick_mood("entry")
        entry_cam = zone_camera.get("entry", cameras[0])
        db.add(MoodLog(visit_id=visit.id, zone="entry", mood=mood, confidence=conf, timestamp=entry_time))
        db.add(DetectionLog(
            visit_id=visit.id, camera_id=entry_cam.id, zone="entry",
            gender=visitor.gender, age_estimate=visitor.age_estimate,
            mood=mood, mood_confidence=conf,
        ))

        # Floor mood (beberapa kali selama visit)
        if dwell_secs > 120:
            floor_cam = zone_camera.get("floor", cameras[0])
            num_floor = min(random.randint(1, 5), dwell_secs // 120)
            for j in range(num_floor):
                t = entry_time + timedelta(seconds=random.randint(60, max(61, dwell_secs - 60)))
                mood, conf = pick_mood("floor")
                db.add(MoodLog(visit_id=visit.id, zone="floor", mood=mood, confidence=conf, timestamp=t))
                db.add(DetectionLog(
                    visit_id=visit.id, camera_id=floor_cam.id, zone="floor",
                    gender=visitor.gender, age_estimate=visitor.age_estimate,
                    mood=mood, mood_confidence=conf, timestamp=t,
                ))

        # Cashier mood (70% chance visitor goes to cashier)
        if random.random() < 0.70 and dwell_secs > 180:
            cashier_cam = zone_camera.get("cashier", cameras[0])
            t = entry_time + timedelta(seconds=int(dwell_secs * random.uniform(0.5, 0.85)))
            mood, conf = pick_mood("cashier")
            db.add(MoodLog(visit_id=visit.id, zone="cashier", mood=mood, confidence=conf, timestamp=t))
            db.add(DetectionLog(
                visit_id=visit.id, camera_id=cashier_cam.id, zone="cashier",
                gender=visitor.gender, age_estimate=visitor.age_estimate,
                mood=mood, mood_confidence=conf, timestamp=t,
            ))

        # Exit mood
        exit_cam = zone_camera.get("exit", cameras[0])
        mood, conf = pick_mood("exit")
        db.add(MoodLog(visit_id=visit.id, zone="exit", mood=mood, confidence=conf, timestamp=exit_time))
        db.add(DetectionLog(
            visit_id=visit.id, camera_id=exit_cam.id, zone="exit",
            gender=visitor.gender, age_estimate=visitor.age_estimate,
            mood=mood, mood_confidence=conf, timestamp=exit_time,
        ))

    await db.flush()
    print(f"   {len(all_visitors)} visitors + visits + mood logs created")


async def seed_traffic_snapshots(
    db: AsyncSession, store: Store, days: int
) -> None:
    """Seed hourly traffic snapshots."""
    now = datetime.now(timezone.utc)
    start = now - timedelta(days=days)

    current = start.replace(minute=0, second=0, microsecond=0)
    count = 0
    while current <= now:
        hour = current.hour
        # Realistic hourly visitor pattern (bell curve, peak 12-14 dan 17-19)
        if 0 <= hour < 9:
            base = random.randint(0, 3)
        elif 9 <= hour < 11:
            base = random.randint(5, 15)
        elif 11 <= hour < 14:
            base = random.randint(15, 35)  # lunch peak
        elif 14 <= hour < 17:
            base = random.randint(10, 25)
        elif 17 <= hour < 20:
            base = random.randint(20, 40)  # evening peak
        elif 20 <= hour < 22:
            base = random.randint(5, 15)
        else:
            base = random.randint(0, 3)

        snapshot = TrafficSnapshot(
            store_id=store.id,
            timestamp=current,
            visitor_count=base,
            avg_dwell_seconds=round(random.uniform(300, 1200), 1),
            peak_count=base + random.randint(0, 10),
        )
        db.add(snapshot)
        count += 1
        current += timedelta(hours=1)

    await db.flush()
    print(f"   {count} hourly traffic snapshots created")


async def seed_shoplifting_alerts(
    db: AsyncSession, store: Store, cameras: list[Camera]
) -> None:
    """Seed beberapa shoplifting alerts sebagai contoh."""
    now = datetime.now(timezone.utc)

    # Get beberapa visit random untuk alert
    from sqlalchemy import select
    result = await db.execute(
        select(Visit).order_by(Visit.entry_at.desc()).limit(200)
    )
    visits = result.scalars().all()
    if not visits:
        return

    floor_cam = next((c for c in cameras if c.location_zone == "floor"), cameras[0])
    alert_count = min(8, len(visits))
    selected = random.sample(list(visits), alert_count)

    for i, visit in enumerate(selected):
        alert = ShopliftingAlert(
            visit_id=visit.id,
            camera_id=floor_cam.id,
            confidence=round(random.uniform(0.75, 0.95), 3),
            timestamp=visit.entry_at + timedelta(minutes=random.randint(2, 15)),
            notified=True,
            resolved=i < 5,  # 5 resolved, 3 unresolved
            resolved_at=(now - timedelta(hours=random.randint(1, 12))) if i < 5 else None,
            resolved_note="False alarm - customer sedang coba baju" if i < 3 else (
                "Confirmed - LP team sudah handle" if i < 5 else None
            ),
        )
        db.add(alert)

    await db.flush()
    print(f"   {alert_count} shoplifting alerts created (5 resolved, 3 open)")


async def main(num_visitors: int = 150, days: int = 1, reset: bool = False) -> None:
    """Main seed function."""
    print("=" * 60)
    print("  Vernon Store Analytics — Seed Data")
    print("=" * 60)
    print(f"  Visitors: {num_visitors} | Period: {days} day(s) | Reset: {reset}")
    print("=" * 60)

    async with AsyncSessionFactory() as db:
        if reset:
            await reset_data(db)

        print("\n[1/5] Users")
        user = await seed_users(db)

        print("\n[2/5] Store & Cameras")
        store, cameras = await seed_store_and_cameras(db)

        print("\n[3/5] Visitors, Visits & Mood Logs")
        await seed_visitors_and_visits(db, store, cameras, num_visitors, days)

        print("\n[4/5] Traffic Snapshots")
        await seed_traffic_snapshots(db, store, days)

        print("\n[5/5] Shoplifting Alerts")
        await seed_shoplifting_alerts(db, store, cameras)

        await db.commit()

    await engine.dispose()

    print("\n" + "=" * 60)
    print("  Seed selesai!")
    print("=" * 60)
    print(f"\n  Login: admin@vernon.com / adminpass123!")
    print(f"  Store: Vernon Flagship Store (id=baru)")
    print(f"  Swagger: http://localhost:8001/docs")
    print()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Seed database dengan data demo")
    parser.add_argument("--visitors", type=int, default=150, help="Jumlah visitor (default: 150)")
    parser.add_argument("--days", type=int, default=1, help="Periode hari (default: 1)")
    parser.add_argument("--reset", action="store_true", help="Hapus semua data sebelum seed")
    args = parser.parse_args()

    asyncio.run(main(num_visitors=args.visitors, days=args.days, reset=args.reset))
