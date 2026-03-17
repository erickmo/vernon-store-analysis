"""
Stream manager — mengelola koneksi ke CCTV dan memproses frame secara periodik.
Mengoordinasikan FrameAnalyzer, PersonTracker, dan penyimpanan ke database.
"""

from __future__ import annotations

import asyncio
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any

import numpy as np
import structlog
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.config import get_settings
from ...core.database import AsyncSessionFactory
from ...models.db.camera import Camera
from ...models.db.detection_log import DetectionLog
from ...models.db.mood_log import MoodLog
from ...models.db.visit import Visit
from ...models.db.visitor import Visitor
from ...models.db.shoplifting_alert import ShopliftingAlert
from .frame_analyzer import FrameAnalyzer, PersonDetection
from .person_tracker import PersonTracker
from .shoplifting_detector import ShopliftingDetector

logger = structlog.get_logger(__name__)
settings = get_settings()


@dataclass
class CameraStream:
    """State satu koneksi CCTV stream."""

    camera_id: int
    store_id: int
    stream_url: str
    zone: str
    is_running: bool = False
    capture: Any = None  # cv2.VideoCapture
    last_frame_at: datetime | None = None
    error_count: int = 0


@dataclass
class StreamStats:
    """Statistik real-time dari stream processor."""

    camera_id: int
    store_id: int
    zone: str
    is_running: bool
    persons_in_frame: int = 0
    total_detections: int = 0
    last_frame_at: datetime | None = None
    fps: float = 0.0


class StreamManager:
    """
    Singleton yang mengelola semua CCTV stream.
    Proses frame dan simpan detection data ke database.
    """

    _instance: StreamManager | None = None

    def __init__(self) -> None:
        self._streams: dict[int, CameraStream] = {}
        self._analyzer = FrameAnalyzer()
        self._tracker = PersonTracker()
        self._shoplifting_detector = ShopliftingDetector()
        self._tasks: dict[int, asyncio.Task] = {}
        self._running = False
        # Active visits: person_uid -> Visit.id
        self._active_visits: dict[str, int] = {}
        # WebSocket clients untuk broadcast
        self._ws_clients: set = set()
        # Latest stats per camera
        self._latest_stats: dict[int, StreamStats] = {}
        # Latest detections per camera (untuk WebSocket broadcast)
        self._latest_detections: dict[int, list[dict]] = {}

    @classmethod
    def get_instance(cls) -> StreamManager:
        """Singleton pattern."""
        if cls._instance is None:
            cls._instance = StreamManager()
        return cls._instance

    async def register_camera(self, camera: Camera) -> None:
        """Register camera untuk dimonitor."""
        self._streams[camera.id] = CameraStream(
            camera_id=camera.id,
            store_id=camera.store_id,
            stream_url=camera.stream_url,
            zone=camera.location_zone,
        )
        logger.info(
            "camera registered for streaming",
            camera_id=camera.id,
            zone=camera.location_zone,
        )

    async def start_camera(self, camera_id: int) -> bool:
        """Mulai streaming dari satu camera."""
        stream = self._streams.get(camera_id)
        if not stream:
            logger.error("camera not registered", camera_id=camera_id)
            return False

        if stream.is_running:
            logger.warning("camera already running", camera_id=camera_id)
            return True

        try:
            import cv2

            capture = cv2.VideoCapture(stream.stream_url)
            if not capture.isOpened():
                logger.error("failed to open stream", camera_id=camera_id, url=stream.stream_url)
                return False

            stream.capture = capture
            stream.is_running = True
            stream.error_count = 0

            # Start background processing task
            task = asyncio.create_task(self._process_stream(camera_id))
            self._tasks[camera_id] = task
            logger.info("stream started", camera_id=camera_id)
            return True

        except ImportError:
            logger.error("opencv not installed")
            return False
        except Exception as e:
            logger.error("failed to start stream", camera_id=camera_id, error=str(e))
            return False

    async def stop_camera(self, camera_id: int) -> None:
        """Stop streaming dari satu camera."""
        stream = self._streams.get(camera_id)
        if not stream:
            return

        stream.is_running = False

        task = self._tasks.pop(camera_id, None)
        if task:
            task.cancel()
            try:
                await task
            except asyncio.CancelledError:
                pass

        if stream.capture:
            stream.capture.release()
            stream.capture = None

        logger.info("stream stopped", camera_id=camera_id)

    async def start_all(self) -> None:
        """Start semua registered camera."""
        self._running = True
        for camera_id in self._streams:
            await self.start_camera(camera_id)

    async def stop_all(self) -> None:
        """Stop semua camera stream."""
        self._running = False
        for camera_id in list(self._tasks.keys()):
            await self.stop_camera(camera_id)

    async def _process_stream(self, camera_id: int) -> None:
        """Background task untuk memproses frame dari satu camera."""
        stream = self._streams[camera_id]
        interval = settings.cctv_frame_interval

        while stream.is_running:
            try:
                ret, frame = stream.capture.read()
                if not ret:
                    stream.error_count += 1
                    if stream.error_count > 10:
                        logger.error("too many read errors, stopping", camera_id=camera_id)
                        stream.is_running = False
                        break
                    await asyncio.sleep(1)
                    continue

                stream.error_count = 0
                stream.last_frame_at = datetime.now(timezone.utc)

                # Analyze frame in thread pool (blocking CV operations)
                loop = asyncio.get_event_loop()
                detections = await loop.run_in_executor(
                    None, self._analyzer.analyze_frame, frame
                )

                if detections:
                    await self._process_detections(
                        detections, frame, stream
                    )

                # Update stats
                self._latest_stats[camera_id] = StreamStats(
                    camera_id=camera_id,
                    store_id=stream.store_id,
                    zone=stream.zone,
                    is_running=True,
                    persons_in_frame=len(detections),
                    last_frame_at=stream.last_frame_at,
                )

                # Broadcast ke WebSocket clients
                await self._broadcast_update(camera_id, detections)

                await asyncio.sleep(interval)

            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error("stream processing error", camera_id=camera_id, error=str(e))
                await asyncio.sleep(interval)

    async def _process_detections(
        self,
        detections: list[PersonDetection],
        frame: np.ndarray,
        stream: CameraStream,
    ) -> None:
        """Proses deteksi — identify person, simpan ke DB."""
        async with AsyncSessionFactory() as db:
            try:
                for det in detections:
                    # Get face embedding untuk re-identification
                    if det.bbox:
                        x, y, w, h = det.bbox
                        face_crop = frame[y : y + h, x : x + w]
                        if face_crop.size > 0:
                            embedding = self._analyzer.get_face_embedding(face_crop)
                            person_uid = self._tracker.identify_or_register(embedding)
                            det.person_uid = person_uid
                            det.face_embedding = embedding

                    # Upsert visitor di DB
                    visitor = await self._upsert_visitor(db, det, stream.store_id)

                    # Upsert visit (active visit untuk person ini)
                    visit = await self._upsert_visit(db, visitor.id, stream.camera_id)

                    # Log mood berdasarkan zone camera
                    mood_log = MoodLog(
                        visit_id=visit.id,
                        zone=stream.zone,
                        mood=det.dominant_emotion or "neutral",
                        confidence=det.emotion_confidence,
                    )
                    db.add(mood_log)

                    # Log detection detail
                    det_log = DetectionLog(
                        visit_id=visit.id,
                        camera_id=stream.camera_id,
                        zone=stream.zone,
                        gender=det.gender,
                        age_estimate=det.age_estimate,
                        mood=det.dominant_emotion,
                        mood_confidence=det.emotion_confidence,
                        bbox_x=det.bbox[0] if det.bbox else None,
                        bbox_y=det.bbox[1] if det.bbox else None,
                        bbox_w=det.bbox[2] if det.bbox else None,
                        bbox_h=det.bbox[3] if det.bbox else None,
                    )
                    db.add(det_log)

                    # Update shoplifting behavior profile
                    self._shoplifting_detector.update_profile(
                        person_uid=det.person_uid,
                        visit_id=visit.id,
                        zone=stream.zone,
                        mood=det.dominant_emotion,
                        mood_confidence=det.emotion_confidence,
                    )

                    # Evaluate shoplifting score
                    score = self._shoplifting_detector.evaluate(det.person_uid)
                    if score and score.is_alert:
                        alert = ShopliftingAlert(
                            visit_id=visit.id,
                            camera_id=stream.camera_id,
                            confidence=score.confidence,
                            notified=False,
                        )
                        db.add(alert)
                        await db.flush()

                        # Broadcast alert ke WebSocket
                        await self._broadcast_shoplifting_alert(
                            alert_id=alert.id,
                            camera_id=stream.camera_id,
                            score=score,
                        )

                await db.commit()

            except Exception as e:
                await db.rollback()
                logger.error("failed to persist detections", error=str(e))

    async def _upsert_visitor(
        self, db: AsyncSession, det: PersonDetection, store_id: int
    ) -> Visitor:
        """Create or update visitor di database."""
        from sqlalchemy import select

        result = await db.execute(
            select(Visitor).where(Visitor.person_uid == det.person_uid)
        )
        visitor = result.scalar_one_or_none()

        now = datetime.now(timezone.utc)

        if visitor:
            visitor.last_seen_at = now
            if det.gender and not visitor.gender:
                visitor.gender = det.gender
            if det.age_estimate and not visitor.age_estimate:
                visitor.age_estimate = det.age_estimate
                visitor.age_group = det.age_group
            if det.face_embedding is not None and not visitor.person_embedding:
                visitor.person_embedding = self._tracker.serialize_embedding(det.face_embedding)
        else:
            visitor = Visitor(
                store_id=store_id,
                person_uid=det.person_uid,
                gender=det.gender,
                age_estimate=det.age_estimate,
                age_group=det.age_group,
                person_embedding=(
                    self._tracker.serialize_embedding(det.face_embedding)
                    if det.face_embedding is not None
                    else None
                ),
                first_seen_at=now,
                last_seen_at=now,
                total_visits=1,
            )
            db.add(visitor)
            await db.flush()

        return visitor

    async def _upsert_visit(self, db: AsyncSession, visitor_id: int, camera_id: int) -> Visit:
        """Get active visit atau buat baru."""
        from sqlalchemy import select

        # Cek apakah ada active visit (belum exit)
        result = await db.execute(
            select(Visit).where(
                Visit.visitor_id == visitor_id,
                Visit.exit_at.is_(None),
            )
        )
        visit = result.scalar_one_or_none()

        if visit:
            return visit

        # Buat visit baru
        visit = Visit(
            visitor_id=visitor_id,
            camera_id=camera_id,
        )
        db.add(visit)
        await db.flush()
        return visit

    async def _broadcast_update(
        self, camera_id: int, detections: list[PersonDetection]
    ) -> None:
        """Broadcast detection data ke WebSocket clients."""
        if not self._ws_clients:
            return

        data = {
            "type": "detection_update",
            "camera_id": camera_id,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "persons_count": len(detections),
            "detections": [
                {
                    "person_uid": d.person_uid,
                    "gender": d.gender,
                    "age_estimate": d.age_estimate,
                    "age_group": d.age_group,
                    "mood": d.dominant_emotion,
                    "mood_confidence": d.emotion_confidence,
                    "bbox": d.bbox,
                }
                for d in detections
            ],
        }

        self._latest_detections[camera_id] = data["detections"]

        import json
        message = json.dumps(data)

        dead_clients = set()
        for ws in self._ws_clients:
            try:
                await ws.send_text(message)
            except Exception:
                dead_clients.add(ws)

        self._ws_clients -= dead_clients

    def add_ws_client(self, ws: Any) -> None:
        """Register WebSocket client."""
        self._ws_clients.add(ws)

    def remove_ws_client(self, ws: Any) -> None:
        """Unregister WebSocket client."""
        self._ws_clients.discard(ws)

    def get_all_stats(self) -> list[StreamStats]:
        """Mendapatkan stats semua camera."""
        stats = []
        for camera_id, stream in self._streams.items():
            stat = self._latest_stats.get(camera_id) or StreamStats(
                camera_id=camera_id,
                store_id=stream.store_id,
                zone=stream.zone,
                is_running=stream.is_running,
            )
            stats.append(stat)
        return stats

    def get_camera_stats(self, camera_id: int) -> StreamStats | None:
        """Mendapatkan stats satu camera."""
        return self._latest_stats.get(camera_id)

    async def _broadcast_shoplifting_alert(
        self, alert_id: int, camera_id: int, score: "ShopliftingScore"
    ) -> None:
        """Broadcast shoplifting alert ke WebSocket clients."""
        if not self._ws_clients:
            return

        import json
        from .shoplifting_detector import ShopliftingScore

        data = {
            "type": "shoplifting_alert",
            "alert_id": alert_id,
            "camera_id": camera_id,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "person_uid": score.person_uid,
            "visit_id": score.visit_id,
            "confidence": round(score.confidence, 3),
            "reasons": score.reasons,
        }

        message = json.dumps(data)
        dead_clients = set()
        for ws in self._ws_clients:
            try:
                await ws.send_text(message)
            except Exception:
                dead_clients.add(ws)
        self._ws_clients -= dead_clients

        logger.warning(
            "shoplifting alert broadcasted",
            alert_id=alert_id,
            person_uid=score.person_uid,
            confidence=round(score.confidence, 3),
        )

    @property
    def shoplifting_detector(self) -> ShopliftingDetector:
        """Access shoplifting detector untuk monitoring/API."""
        return self._shoplifting_detector

    @property
    def active_camera_count(self) -> int:
        """Jumlah camera yang aktif streaming."""
        return sum(1 for s in self._streams.values() if s.is_running)

    @property
    def registered_camera_count(self) -> int:
        """Jumlah camera yang terdaftar."""
        return len(self._streams)
