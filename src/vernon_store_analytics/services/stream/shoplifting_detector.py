"""
Shoplifting detector — behavior-based scoring system.

Menganalisis pola perilaku mencurigakan dari detection data:
- Lama di satu zona tanpa ke kasir
- Gerakan tidak wajar (sering keluar-masuk area)
- Mood nervous/fear yang konsisten
- Dwell time sangat lama tapi tidak ke kasir
- Pergerakan cepat antar zona

Scoring menghasilkan confidence 0.0 - 1.0.
Alert dibuat jika confidence > threshold (default 0.75 dari config).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone

import structlog

from ...core.config import get_settings

logger = structlog.get_logger(__name__)
settings = get_settings()


@dataclass
class BehaviorProfile:
    """Profil perilaku satu visitor selama kunjungan."""

    person_uid: str
    visit_id: int
    first_seen: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
    last_seen: datetime = field(default_factory=lambda: datetime.now(timezone.utc))

    # Zone tracking
    zones_visited: list[str] = field(default_factory=list)
    zone_timestamps: list[tuple[str, datetime]] = field(default_factory=list)
    zone_dwell: dict[str, float] = field(default_factory=dict)  # zone -> total seconds

    # Mood tracking
    moods: list[tuple[str, float]] = field(default_factory=list)  # (mood, confidence)
    nervous_count: int = 0  # fear + angry + disgust count

    # Movement
    zone_changes: int = 0
    detection_count: int = 0

    # Flags
    visited_cashier: bool = False
    visited_exit: bool = False

    @property
    def total_dwell_seconds(self) -> float:
        """Total waktu di dalam store."""
        return (self.last_seen - self.first_seen).total_seconds()

    @property
    def dominant_mood(self) -> str | None:
        """Mood yang paling sering muncul."""
        if not self.moods:
            return None
        mood_counts: dict[str, int] = {}
        for mood, _ in self.moods:
            mood_counts[mood] = mood_counts.get(mood, 0) + 1
        return max(mood_counts, key=mood_counts.get)

    @property
    def nervous_ratio(self) -> float:
        """Rasio mood nervous (fear/angry/disgust) terhadap total mood."""
        if not self.moods:
            return 0.0
        return self.nervous_count / len(self.moods)


@dataclass
class ShopliftingScore:
    """Hasil scoring shoplifting detection."""

    person_uid: str
    visit_id: int
    confidence: float
    reasons: list[str]
    is_alert: bool

    def to_dict(self) -> dict:
        """Convert ke dictionary."""
        return {
            "person_uid": self.person_uid,
            "visit_id": self.visit_id,
            "confidence": round(self.confidence, 3),
            "reasons": self.reasons,
            "is_alert": self.is_alert,
        }


# ── Scoring Rules ─────────────────────────────────────────────
# Setiap rule return (score, reason) — score 0.0-1.0

def _rule_long_dwell_no_cashier(profile: BehaviorProfile) -> tuple[float, str | None]:
    """Lama di store tapi tidak ke kasir — mencurigakan setelah 10+ menit."""
    dwell = profile.total_dwell_seconds
    if dwell > 600 and not profile.visited_cashier:
        score = min(0.35, 0.15 + (dwell - 600) / 1800 * 0.20)
        return score, f"Dwell {int(dwell/60)} menit tanpa ke kasir"
    return 0.0, None


def _rule_nervous_behavior(profile: BehaviorProfile) -> tuple[float, str | None]:
    """Mood nervous (fear/angry/disgust) yang konsisten."""
    ratio = profile.nervous_ratio
    if ratio > 0.3 and len(profile.moods) >= 3:
        score = min(0.35, ratio * 0.35)
        return score, f"Mood nervous {int(ratio*100)}% dari {len(profile.moods)} deteksi"
    return 0.0, None


def _rule_frequent_zone_changes(profile: BehaviorProfile) -> tuple[float, str | None]:
    """Sering berpindah zona — mondar-mandir mencurigakan."""
    if profile.zone_changes >= 3:
        dwell = max(profile.total_dwell_seconds, 1)
        change_rate = profile.zone_changes / (dwell / 60)
        score = min(0.25, 0.10 + profile.zone_changes * 0.03)
        return score, f"{profile.zone_changes} perpindahan zona dalam {int(dwell/60)} menit"
    return 0.0, None


def _rule_lingering_floor_only(profile: BehaviorProfile) -> tuple[float, str | None]:
    """Hanya di area floor terlalu lama tanpa interaksi zona lain."""
    floor_time = profile.zone_dwell.get("floor", 0)
    total = profile.total_dwell_seconds
    if total > 300 and floor_time / max(total, 1) > 0.70:
        unique_zones = set(profile.zones_visited)
        if "cashier" not in unique_zones:
            score = min(0.20, 0.10 + (floor_time - 300) / 1200 * 0.10)
            return score, f"Hanya di area floor {int(floor_time/60)} menit"
    return 0.0, None


def _rule_exit_without_cashier(profile: BehaviorProfile) -> tuple[float, str | None]:
    """Menuju exit setelah lama di floor tanpa ke kasir."""
    if (
        profile.visited_exit
        and not profile.visited_cashier
        and profile.total_dwell_seconds > 300
    ):
        return 0.20, "Keluar store tanpa ke kasir setelah 5+ menit"
    return 0.0, None


def _rule_rapid_entry_exit(profile: BehaviorProfile) -> tuple[float, str | None]:
    """Masuk dan langsung keluar dengan sangat cepat (grab & run)."""
    dwell = profile.total_dwell_seconds
    if (
        dwell < 120
        and profile.visited_exit
        and profile.zone_changes >= 2
        and not profile.visited_cashier
    ):
        score = max(0.0, 0.30 - (dwell / 600))
        if score > 0:
            return score, f"Entry-exit cepat ({int(dwell)} detik) tanpa kasir"
    return 0.0, None


# All rules
RULES = [
    _rule_long_dwell_no_cashier,
    _rule_nervous_behavior,
    _rule_frequent_zone_changes,
    _rule_lingering_floor_only,
    _rule_exit_without_cashier,
    _rule_rapid_entry_exit,
]


class ShopliftingDetector:
    """
    Mendeteksi potensi shoplifting berdasarkan behavior scoring.

    Cara kerja:
    1. Stream processor memanggil update_profile() setiap deteksi
    2. evaluate() dipanggil periodik untuk scoring
    3. Jika score > threshold → return ShopliftingScore dengan is_alert=True
    """

    def __init__(self, threshold: float | None = None) -> None:
        self.threshold = threshold or settings.shoplifting_threshold
        self._profiles: dict[str, BehaviorProfile] = {}
        # Cooldown: person_uid -> last alert time
        self._alert_cooldown: dict[str, datetime] = {}
        self._cooldown_seconds = settings.shoplifting_notification_cooldown_seconds

    def update_profile(
        self,
        person_uid: str,
        visit_id: int,
        zone: str,
        mood: str | None = None,
        mood_confidence: float = 0.0,
    ) -> None:
        """
        Update behavior profile dengan detection baru.
        Dipanggil oleh stream processor setiap kali person terdeteksi.
        """
        now = datetime.now(timezone.utc)

        if person_uid not in self._profiles:
            self._profiles[person_uid] = BehaviorProfile(
                person_uid=person_uid,
                visit_id=visit_id,
                first_seen=now,
            )

        profile = self._profiles[person_uid]
        profile.last_seen = now
        profile.detection_count += 1

        # Track zone
        prev_zone = profile.zones_visited[-1] if profile.zones_visited else None
        profile.zones_visited.append(zone)
        profile.zone_timestamps.append((zone, now))

        if zone != prev_zone and prev_zone is not None:
            profile.zone_changes += 1

        if zone == "cashier":
            profile.visited_cashier = True
        if zone == "exit":
            profile.visited_exit = True

        # Update zone dwell (rough: tambah interval sejak last detection)
        if len(profile.zone_timestamps) >= 2:
            _, prev_time = profile.zone_timestamps[-2]
            elapsed = (now - prev_time).total_seconds()
            if prev_zone:
                profile.zone_dwell[prev_zone] = profile.zone_dwell.get(prev_zone, 0) + elapsed

        # Track mood
        if mood:
            profile.moods.append((mood, mood_confidence))
            if mood in ("fear", "angry", "disgust"):
                profile.nervous_count += 1

    def evaluate(self, person_uid: str) -> ShopliftingScore | None:
        """
        Evaluate behavior profile dan return score.
        Return None jika person belum ditrack atau dalam cooldown.
        """
        profile = self._profiles.get(person_uid)
        if not profile:
            return None

        # Check cooldown
        now = datetime.now(timezone.utc)
        last_alert = self._alert_cooldown.get(person_uid)
        if last_alert and (now - last_alert).total_seconds() < self._cooldown_seconds:
            return None

        # Run semua rules
        total_score = 0.0
        reasons = []

        for rule in RULES:
            score, reason = rule(profile)
            if score > 0 and reason:
                total_score += score
                reasons.append(reason)

        # Clamp score ke 0.0 - 1.0
        confidence = min(1.0, total_score)

        is_alert = confidence >= self.threshold

        if is_alert:
            self._alert_cooldown[person_uid] = now
            logger.warning(
                "shoplifting alert triggered",
                person_uid=person_uid,
                visit_id=profile.visit_id,
                confidence=round(confidence, 3),
                reasons=reasons,
            )

        return ShopliftingScore(
            person_uid=person_uid,
            visit_id=profile.visit_id,
            confidence=confidence,
            reasons=reasons,
            is_alert=is_alert,
        )

    def evaluate_all(self) -> list[ShopliftingScore]:
        """Evaluate semua active profiles, return hanya yang alert."""
        alerts = []
        for person_uid in list(self._profiles.keys()):
            result = self.evaluate(person_uid)
            if result and result.is_alert:
                alerts.append(result)
        return alerts

    def remove_profile(self, person_uid: str) -> None:
        """Hapus profile (saat visitor sudah keluar store)."""
        self._profiles.pop(person_uid, None)

    def get_profile(self, person_uid: str) -> BehaviorProfile | None:
        """Get behavior profile untuk debugging/monitoring."""
        return self._profiles.get(person_uid)

    def get_all_scores(self) -> list[ShopliftingScore]:
        """Get score semua active profiles (termasuk non-alert)."""
        scores = []
        for person_uid in self._profiles:
            profile = self._profiles[person_uid]
            total_score = 0.0
            reasons = []
            for rule in RULES:
                score, reason = rule(profile)
                if score > 0 and reason:
                    total_score += score
                    reasons.append(reason)
            scores.append(ShopliftingScore(
                person_uid=person_uid,
                visit_id=profile.visit_id,
                confidence=min(1.0, total_score),
                reasons=reasons,
                is_alert=min(1.0, total_score) >= self.threshold,
            ))
        return sorted(scores, key=lambda s: s.confidence, reverse=True)

    @property
    def active_profiles_count(self) -> int:
        """Jumlah visitor yang sedang ditrack."""
        return len(self._profiles)
