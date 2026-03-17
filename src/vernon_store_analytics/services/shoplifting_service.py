"""Business logic untuk Shoplifting Detection dari video stream."""

from __future__ import annotations

from datetime import datetime, timezone

import structlog

from ..core.config import get_settings
from ..core.exceptions import NotFoundException, ValidationException
from ..models.db.shoplifting_alert import ShopliftingAlert
from ..repositories.alert_repository import AlertRepository
from ..repositories.visit_repository import VisitRepository
from ..services.stream.shoplifting_detector import ShopliftingDetector, BehaviorProfile
from ..services.stream.stream_manager import StreamManager

logger = structlog.get_logger(__name__)
settings = get_settings()


class ShopliftingService:
    """
    Service layer untuk shoplifting detection dari CCTV stream.

    Tanggung jawab:
    - Coordinate behavior tracking dan scoring
    - Create dan manage shoplifting alerts
    - Provide insights tentang suspicious behavior
    """

    def __init__(
        self,
        alert_repo: AlertRepository,
        visit_repo: VisitRepository,
    ) -> None:
        self.alert_repo = alert_repo
        self.visit_repo = visit_repo
        self.stream_manager = StreamManager.get_instance()
        self.detector = self.stream_manager.shoplifting_detector

    async def get_person_behavior_profile(
        self, person_uid: str
    ) -> dict | None:
        """
        Dapatkan behavior profile untuk satu person yang sedang ditrack.

        Args:
            person_uid: Unique identifier untuk visitor

        Returns:
            Dictionary dengan behavior profile atau None jika tidak ditrack
        """
        profile = self.detector.get_profile(person_uid)
        if not profile:
            return None

        return {
            "person_uid": person_uid,
            "visit_id": profile.visit_id,
            "first_seen": profile.first_seen.isoformat(),
            "last_seen": profile.last_seen.isoformat(),
            "total_dwell_seconds": profile.total_dwell_seconds,
            "zones_visited": profile.zones_visited,
            "zone_dwell": profile.zone_dwell,
            "zone_changes": profile.zone_changes,
            "detection_count": profile.detection_count,
            "moods": [
                {"mood": mood, "confidence": round(conf, 3)}
                for mood, conf in profile.moods
            ],
            "nervous_ratio": round(profile.nervous_ratio, 3),
            "visited_cashier": profile.visited_cashier,
            "visited_exit": profile.visited_exit,
            "dominant_mood": profile.dominant_mood,
        }

    async def evaluate_person_behavior(
        self, person_uid: str
    ) -> dict | None:
        """
        Evaluate behavior profile dan return scoring result.

        Args:
            person_uid: Unique identifier untuk visitor

        Returns:
            Dictionary dengan score, confidence, dan reasons atau None
        """
        score = self.detector.evaluate(person_uid)
        if not score:
            return None

        return score.to_dict()

    async def get_active_profiles_count(self) -> int:
        """Dapatkan jumlah visitor yang sedang ditrack."""
        return self.detector.active_profiles_count

    async def get_all_suspicious_persons(
        self, threshold: float | None = None
    ) -> list[dict]:
        """
        Dapatkan semua person dengan suspicious score di atas threshold.

        Args:
            threshold: Custom threshold, default dari config

        Returns:
            List of scores (sorted by confidence, descending)
        """
        threshold = threshold or settings.shoplifting_threshold
        all_scores = self.detector.get_all_scores()

        return [
            score.to_dict()
            for score in all_scores
            if score.confidence >= threshold
        ]

    async def create_alert_from_detection(
        self,
        visit_id: int,
        camera_id: int,
        confidence: float,
        person_uid: str,
        reasons: list[str],
    ) -> ShopliftingAlert:
        """
        Create shoplifting alert dari detection result.

        Args:
            visit_id: Visit ID yang terdeteksi
            camera_id: Camera ID yang mendeteksi
            confidence: Confidence score (0.0-1.0)
            person_uid: Person UID untuk reference
            reasons: List of reasons untuk alert

        Returns:
            Created ShopliftingAlert

        Raises:
            ValidationException: Jika visit tidak ditemukan atau invalid
        """
        visit = await self.visit_repo.get_by_id(visit_id)
        if not visit:
            raise NotFoundException("Visit")

        # Validate confidence
        if not 0.0 <= confidence <= 1.0:
            raise ValidationException("Confidence harus antara 0.0 dan 1.0")

        alert = ShopliftingAlert(
            visit_id=visit_id,
            camera_id=camera_id,
            confidence=confidence,
            notified=False,
        )

        created_alert = await self.alert_repo.create(alert)

        logger.warning(
            "shoplifting alert created",
            alert_id=created_alert.id,
            visit_id=visit_id,
            camera_id=camera_id,
            person_uid=person_uid,
            confidence=round(confidence, 3),
            reasons=reasons,
        )

        return created_alert

    async def list_unresolved_alerts(
        self,
        store_id: int,
        limit: int = 50,
        offset: int = 0,
    ) -> list[ShopliftingAlert]:
        """
        Dapatkan unresolved alerts untuk store tertentu.

        Args:
            store_id: Store ID
            limit: Max results
            offset: Pagination offset

        Returns:
            List of ShopliftingAlert
        """
        return await self.alert_repo.get_by_store(
            store_id=store_id,
            resolved=False,
            limit=limit,
            offset=offset,
        )

    async def get_alert_statistics(self, store_id: int) -> dict:
        """
        Dapatkan statistics untuk shoplifting alerts.

        Args:
            store_id: Store ID

        Returns:
            Dictionary dengan statistics
        """
        unresolved = await self.list_unresolved_alerts(
            store_id=store_id,
            limit=1000,  # Get all untuk statistics
        )
        resolved = await self.alert_repo.get_by_store(
            store_id=store_id,
            resolved=True,
            limit=1000,
        )

        total_alerts = len(unresolved) + len(resolved)
        avg_confidence = 0.0
        if total_alerts > 0:
            total_confidence = sum(a.confidence for a in (unresolved + resolved))
            avg_confidence = round(total_confidence / total_alerts, 3)

        return {
            "store_id": store_id,
            "total_alerts": total_alerts,
            "unresolved_count": len(unresolved),
            "resolved_count": len(resolved),
            "average_confidence": avg_confidence,
            "min_confidence": min(
                (a.confidence for a in (unresolved + resolved)),
                default=0.0,
            ),
            "max_confidence": max(
                (a.confidence for a in (unresolved + resolved)),
                default=0.0,
            ),
        }

    async def mark_alert_reviewed(
        self,
        alert_id: int,
        resolved_note: str | None = None,
    ) -> ShopliftingAlert:
        """
        Mark alert sebagai reviewed/resolved.

        Args:
            alert_id: Alert ID
            resolved_note: Optional note

        Returns:
            Updated ShopliftingAlert
        """
        alert = await self.alert_repo.get_by_id(alert_id)
        if not alert:
            raise NotFoundException("Alert")

        if alert.resolved:
            raise ValidationException("Alert sudah di-resolve sebelumnya")

        resolved_alert = await self.alert_repo.resolve(
            alert,
            note=resolved_note,
        )

        logger.info(
            "alert marked as resolved",
            alert_id=alert.id,
            resolved_note=resolved_note,
        )

        return resolved_alert

    async def get_person_alert_history(
        self,
        person_uid: str,
        limit: int = 10,
    ) -> list[ShopliftingAlert]:
        """
        Dapatkan alert history untuk satu person.

        Args:
            person_uid: Person UID
            limit: Max results

        Returns:
            List of ShopliftingAlert untuk person ini
        """
        # Find all visits untuk person ini, then get alerts
        # Untuk sekarang, return empty — ini membutuhkan visitor lookup
        # TODO: implement visitor lookup dan visit history
        return []
