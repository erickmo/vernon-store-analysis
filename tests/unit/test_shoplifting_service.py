"""Unit tests untuk ShopliftingService."""

from __future__ import annotations

from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock

import pytest

from src.vernon_store_analytics.services.shoplifting_service import ShopliftingService
from src.vernon_store_analytics.core.exceptions import NotFoundException, ValidationException
from src.vernon_store_analytics.services.stream.shoplifting_detector import (
    ShopliftingScore,
    BehaviorProfile,
)
from src.vernon_store_analytics.models.db.shoplifting_alert import ShopliftingAlert


# ── Fixtures ──────────────────────────────────────────────────

@pytest.fixture
def mock_alert_repo():
    """Mock AlertRepository untuk isolasi dari database."""
    repo = MagicMock()
    repo.get_by_id = AsyncMock()
    repo.get_by_store = AsyncMock()
    repo.create = AsyncMock()
    repo.resolve = AsyncMock()
    return repo


@pytest.fixture
def mock_visit_repo():
    """Mock VisitRepository untuk isolasi dari database."""
    repo = MagicMock()
    repo.get_by_id = AsyncMock()
    return repo


@pytest.fixture
def mock_stream_manager():
    """Mock StreamManager untuk isolasi detector."""
    manager = MagicMock()
    manager.shoplifting_detector = MagicMock()
    return manager


@pytest.fixture
def service(mock_alert_repo, mock_visit_repo, monkeypatch):
    """ShopliftingService dengan dependency di-inject sebagai mock."""
    service_instance = ShopliftingService(
        alert_repo=mock_alert_repo,
        visit_repo=mock_visit_repo,
    )
    return service_instance


@pytest.fixture
def sample_behavior_profile():
    """Sample behavior profile untuk testing."""
    profile = BehaviorProfile(
        person_uid="person_123",
        visit_id=1,
        first_seen=datetime.now(timezone.utc),
        last_seen=datetime.now(timezone.utc),
        zones_visited=["floor", "cashier"],
        zone_dwell={"floor": 600.0, "cashier": 30.0},
        zone_changes=1,
        detection_count=5,
        visited_cashier=True,
        visited_exit=False,
    )
    profile.moods = [("neutral", 0.9), ("happy", 0.8)]
    return profile


@pytest.fixture
def sample_alert():
    """Sample ShopliftingAlert untuk testing."""
    alert = ShopliftingAlert(
        id=1,
        visit_id=1,
        camera_id=1,
        confidence=0.85,
        notified=False,
        resolved=False,
    )
    return alert


# ── Test: get_person_behavior_profile ─────────────────────────

@pytest.mark.asyncio
async def test_get_behavior_profile_found(
    test_reporter,
    service,
    sample_behavior_profile,
):
    """Person yang sedang ditrack — return behavior profile."""
    test_reporter \
        .scenario("Person dengan UID tertentu sedang ditrack oleh detector") \
        .goal("Service return behavior profile lengkap dalam dict format") \
        .flow(
            "service.get_person_behavior_profile(uid) → "
            "detector.get_profile() return profile → format dict → return"
        )

    # Setup
    service.detector.get_profile = MagicMock(return_value=sample_behavior_profile)

    # Execute
    result = await service.get_person_behavior_profile("person_123")

    # Assert
    assert result is not None
    assert result["person_uid"] == "person_123"
    assert result["visit_id"] == 1
    assert result["total_dwell_seconds"] > 0
    assert result["visited_cashier"] is True
    assert len(result["zones_visited"]) == 2
    test_reporter.result("Behavior profile berhasil diformat dan dikembalikan")


@pytest.mark.asyncio
async def test_get_behavior_profile_not_tracked(test_reporter, service):
    """Person tidak sedang ditrack — return None."""
    test_reporter \
        .scenario("Person UID tidak ada di dalam active profiles") \
        .goal("Service return None tanpa error") \
        .flow(
            "service.get_person_behavior_profile(unknown_uid) → "
            "detector.get_profile() return None → return None"
        )

    # Setup
    service.detector.get_profile = MagicMock(return_value=None)

    # Execute
    result = await service.get_person_behavior_profile("unknown_person")

    # Assert
    assert result is None
    test_reporter.result("None dikembalikan untuk person yang tidak ditrack")


# ── Test: evaluate_person_behavior ────────────────────────────

@pytest.mark.asyncio
async def test_evaluate_person_behavior_alert(test_reporter, service):
    """Person dengan behavior mencurigakan — return alert score."""
    test_reporter \
        .scenario("Person memiliki suspicious behavior score di atas threshold") \
        .goal("Service return score dict dengan is_alert=True dan reasons") \
        .flow(
            "service.evaluate_person_behavior(uid) → "
            "detector.evaluate() → ShopliftingScore(is_alert=True) → to_dict() → return"
        )

    # Setup
    score = ShopliftingScore(
        person_uid="person_123",
        visit_id=1,
        confidence=0.85,
        reasons=["Dwell 15 menit tanpa ke kasir", "Mood nervous 50%"],
        is_alert=True,
    )
    service.detector.evaluate = MagicMock(return_value=score)

    # Execute
    result = await service.evaluate_person_behavior("person_123")

    # Assert
    assert result is not None
    assert result["is_alert"] is True
    assert result["confidence"] == 0.85
    assert len(result["reasons"]) == 2
    test_reporter.result("Score alert berhasil dikembalikan dengan reasons")


@pytest.mark.asyncio
async def test_evaluate_person_behavior_no_alert(test_reporter, service):
    """Person dengan behavior normal — return score tanpa alert."""
    test_reporter \
        .scenario("Person memiliki normal behavior, score di bawah threshold") \
        .goal("Service return score dict dengan is_alert=False") \
        .flow(
            "service.evaluate_person_behavior(uid) → "
            "detector.evaluate() → ShopliftingScore(is_alert=False) → to_dict()"
        )

    # Setup
    score = ShopliftingScore(
        person_uid="person_456",
        visit_id=2,
        confidence=0.35,
        reasons=[],
        is_alert=False,
    )
    service.detector.evaluate = MagicMock(return_value=score)

    # Execute
    result = await service.evaluate_person_behavior("person_456")

    # Assert
    assert result is not None
    assert result["is_alert"] is False
    assert result["confidence"] == 0.35
    test_reporter.result("Score normal (non-alert) dikembalikan dengan alasan kosong")


@pytest.mark.asyncio
async def test_evaluate_person_behavior_not_tracked(test_reporter, service):
    """Person tidak ditrack — return None."""
    test_reporter \
        .scenario("Person UID tidak ada di dalam active profiles detector") \
        .goal("Service return None tanpa error") \
        .flow(
            "service.evaluate_person_behavior(unknown_uid) → "
            "detector.evaluate() return None → return None"
        )

    # Setup
    service.detector.evaluate = MagicMock(return_value=None)

    # Execute
    result = await service.evaluate_person_behavior("unknown_person")

    # Assert
    assert result is None
    test_reporter.result("None dikembalikan untuk person tidak ditrack")


# ── Test: get_active_profiles_count ───────────────────────────

@pytest.mark.asyncio
async def test_get_active_profiles_count_multiple(test_reporter, service):
    """Beberapa person sedang ditrack — return count."""
    test_reporter \
        .scenario("Detector sedang tracking 5 visitor aktif") \
        .goal("Service return integer count dari active profiles") \
        .flow(
            "service.get_active_profiles_count() → "
            "detector.active_profiles_count property → return 5"
        )

    # Setup
    service.detector.active_profiles_count = 5

    # Execute
    result = await service.get_active_profiles_count()

    # Assert
    assert result == 5
    test_reporter.result("Count 5 active profiles berhasil dikembalikan")


@pytest.mark.asyncio
async def test_get_active_profiles_count_empty(test_reporter, service):
    """Tidak ada person yang ditrack — return 0."""
    test_reporter \
        .scenario("Detector tidak sedang tracking siapa pun (stream belum berjalan)") \
        .goal("Service return 0") \
        .flow(
            "service.get_active_profiles_count() → "
            "detector.active_profiles_count = 0 → return 0"
        )

    # Setup
    service.detector.active_profiles_count = 0

    # Execute
    result = await service.get_active_profiles_count()

    # Assert
    assert result == 0
    test_reporter.result("Count 0 dikembalikan saat tidak ada profile aktif")


# ── Test: get_all_suspicious_persons ──────────────────────────

@pytest.mark.asyncio
async def test_get_all_suspicious_persons_multiple(test_reporter, service):
    """Ada beberapa person dengan score mencurigakan — return list."""
    test_reporter \
        .scenario("Detector tracking 3 person, 2 diantaranya score > 0.75") \
        .goal("Service return list 2 scores yang > threshold") \
        .flow(
            "service.get_all_suspicious_persons() → "
            "detector.get_all_scores() → filter by threshold → return list"
        )

    # Setup
    scores = [
        ShopliftingScore("p1", 1, 0.85, ["reason1"], True),
        ShopliftingScore("p2", 2, 0.82, ["reason2"], True),
        ShopliftingScore("p3", 3, 0.35, [], False),
    ]
    service.detector.get_all_scores = MagicMock(return_value=scores)

    # Execute
    result = await service.get_all_suspicious_persons(threshold=0.75)

    # Assert
    assert len(result) == 2
    assert all(s["confidence"] >= 0.75 for s in result)
    assert result[0]["confidence"] == 0.85
    test_reporter.result("2 suspicious persons dengan score 0.85 dan 0.82 dikembalikan")


@pytest.mark.asyncio
async def test_get_all_suspicious_persons_custom_threshold(test_reporter, service):
    """Custom threshold — filter sesuai threshold baru."""
    test_reporter \
        .scenario("Custom threshold 0.80 diberikan, ada score 0.85, 0.78") \
        .goal("Service filter dan return hanya score >= 0.80") \
        .flow(
            "service.get_all_suspicious_persons(threshold=0.80) → "
            "detector.get_all_scores() → filter >= 0.80 → return 1 score"
        )

    # Setup
    scores = [
        ShopliftingScore("p1", 1, 0.85, ["reason1"], True),
        ShopliftingScore("p2", 2, 0.78, ["reason2"], True),
    ]
    service.detector.get_all_scores = MagicMock(return_value=scores)

    # Execute
    result = await service.get_all_suspicious_persons(threshold=0.80)

    # Assert
    assert len(result) == 1
    assert result[0]["person_uid"] == "p1"
    test_reporter.result("Custom threshold 0.80 applied, 1 score >= threshold")


# ── Test: create_alert_from_detection ─────────────────────────

@pytest.mark.asyncio
async def test_create_alert_from_detection_success(
    test_reporter,
    service,
    mock_visit_repo,
    mock_alert_repo,
    sample_alert,
):
    """Valid detection data — alert berhasil dibuat."""
    test_reporter \
        .scenario("Valid detection dengan visit_id, camera_id, confidence valid") \
        .goal("Alert berhasil dibuat dan disimpan, return ShopliftingAlert") \
        .flow(
            "service.create_alert_from_detection(data) → "
            "validate visit exist → repo.create(alert) → return alert"
        )

    # Setup
    mock_visit = MagicMock(id=1)
    mock_visit_repo.get_by_id.return_value = mock_visit
    mock_alert_repo.create.return_value = sample_alert

    # Execute
    result = await service.create_alert_from_detection(
        visit_id=1,
        camera_id=1,
        confidence=0.85,
        person_uid="person_123",
        reasons=["reason1", "reason2"],
    )

    # Assert
    assert result.id == sample_alert.id
    assert result.confidence == 0.85
    mock_alert_repo.create.assert_awaited_once()
    test_reporter.result("Alert dengan confidence 0.85 berhasil dibuat")


@pytest.mark.asyncio
async def test_create_alert_from_detection_invalid_visit(
    test_reporter,
    service,
    mock_visit_repo,
):
    """Visit tidak ditemukan — raise NotFoundException."""
    test_reporter \
        .scenario("visit_id tidak ada di database") \
        .goal("Service raise NotFoundException sebelum create alert") \
        .flow(
            "service.create_alert_from_detection(invalid_visit_id) → "
            "visit_repo.get_by_id() return None → raise NotFoundException"
        )

    # Setup
    mock_visit_repo.get_by_id.return_value = None

    # Execute & Assert
    with pytest.raises(NotFoundException):
        await service.create_alert_from_detection(
            visit_id=9999,
            camera_id=1,
            confidence=0.85,
            person_uid="person_123",
            reasons=["reason1"],
        )

    test_reporter.result("NotFoundException raised untuk visit tidak ditemukan")


@pytest.mark.asyncio
async def test_create_alert_from_detection_invalid_confidence(
    test_reporter,
    service,
    mock_visit_repo,
):
    """Confidence di luar range 0.0-1.0 — raise ValidationException."""
    test_reporter \
        .scenario("Confidence 1.5 (> 1.0) diberikan") \
        .goal("Service raise ValidationException") \
        .flow(
            "service.create_alert_from_detection(confidence=1.5) → "
            "validate confidence 0.0-1.0 → raise ValidationException"
        )

    # Setup
    mock_visit = MagicMock(id=1)
    mock_visit_repo.get_by_id.return_value = mock_visit

    # Execute & Assert
    with pytest.raises(ValidationException):
        await service.create_alert_from_detection(
            visit_id=1,
            camera_id=1,
            confidence=1.5,
            person_uid="person_123",
            reasons=["reason1"],
        )

    test_reporter.result("ValidationException raised untuk confidence invalid")


# ── Test: list_unresolved_alerts ──────────────────────────────

@pytest.mark.asyncio
async def test_list_unresolved_alerts_found(test_reporter, service, mock_alert_repo):
    """Ada unresolved alerts — return list."""
    test_reporter \
        .scenario("Store memiliki 3 unresolved shoplifting alerts") \
        .goal("Service return list 3 alerts yang belum di-resolve") \
        .flow(
            "service.list_unresolved_alerts(store_id) → "
            "alert_repo.get_by_store(resolved=False) → return list(3)"
        )

    # Setup
    alerts = [
        MagicMock(id=1, confidence=0.85),
        MagicMock(id=2, confidence=0.80),
        MagicMock(id=3, confidence=0.75),
    ]
    mock_alert_repo.get_by_store.return_value = alerts

    # Execute
    result = await service.list_unresolved_alerts(store_id=1)

    # Assert
    assert len(result) == 3
    mock_alert_repo.get_by_store.assert_awaited_once_with(
        store_id=1,
        resolved=False,
        limit=50,
        offset=0,
    )
    test_reporter.result("3 unresolved alerts berhasil dikembalikan")


@pytest.mark.asyncio
async def test_list_unresolved_alerts_empty(test_reporter, service, mock_alert_repo):
    """Tidak ada unresolved alerts — return list kosong."""
    test_reporter \
        .scenario("Store tidak memiliki alert yang belum di-resolve") \
        .goal("Service return empty list") \
        .flow(
            "service.list_unresolved_alerts(store_id) → "
            "alert_repo.get_by_store(resolved=False) → return [empty]"
        )

    # Setup
    mock_alert_repo.get_by_store.return_value = []

    # Execute
    result = await service.list_unresolved_alerts(store_id=1)

    # Assert
    assert result == []
    test_reporter.result("Empty list dikembalikan saat tidak ada unresolved alerts")


# ── Test: get_alert_statistics ───────────────────────────────

@pytest.mark.asyncio
async def test_get_alert_statistics_with_alerts(test_reporter, service, mock_alert_repo):
    """Ada alerts — return statistics."""
    test_reporter \
        .scenario("Store punya 5 alerts: 2 unresolved, 3 resolved") \
        .goal("Return statistics dengan total, counts, dan average confidence") \
        .flow(
            "service.get_alert_statistics(store_id) → "
            "get unresolved + resolved → calculate stats → return dict"
        )

    # Setup
    unresolved = [
        MagicMock(id=1, confidence=0.90),
        MagicMock(id=2, confidence=0.85),
    ]
    resolved = [
        MagicMock(id=3, confidence=0.80),
        MagicMock(id=4, confidence=0.75),
        MagicMock(id=5, confidence=0.70),
    ]

    async def get_by_store_side_effect(store_id, resolved, limit, offset):
        if resolved is False:
            return unresolved
        return resolved

    mock_alert_repo.get_by_store.side_effect = get_by_store_side_effect

    # Execute
    result = await service.get_alert_statistics(store_id=1)

    # Assert
    assert result["store_id"] == 1
    assert result["total_alerts"] == 5
    assert result["unresolved_count"] == 2
    assert result["resolved_count"] == 3
    assert result["average_confidence"] == 0.8
    assert result["max_confidence"] == 0.9
    assert result["min_confidence"] == 0.7
    test_reporter.result("Statistics: 5 total, avg 0.8 confidence calculated")


@pytest.mark.asyncio
async def test_get_alert_statistics_no_alerts(test_reporter, service, mock_alert_repo):
    """Tidak ada alerts — return zero statistics."""
    test_reporter \
        .scenario("Store baru tanpa ada alert sama sekali") \
        .goal("Return statistics dengan semua count = 0") \
        .flow(
            "service.get_alert_statistics(store_id) → "
            "no alerts found → return zero stats"
        )

    # Setup
    mock_alert_repo.get_by_store.return_value = []

    # Execute
    result = await service.get_alert_statistics(store_id=1)

    # Assert
    assert result["total_alerts"] == 0
    assert result["unresolved_count"] == 0
    assert result["resolved_count"] == 0
    assert result["average_confidence"] == 0.0
    test_reporter.result("Zero statistics dikembalikan untuk store tanpa alerts")


# ── Test: mark_alert_reviewed ─────────────────────────────────

@pytest.mark.asyncio
async def test_mark_alert_reviewed_success(
    test_reporter,
    service,
    mock_alert_repo,
):
    """Alert exists dan belum di-resolve — mark as resolved."""
    test_reporter \
        .scenario("Unresolved alert dengan note dari reviewer") \
        .goal("Alert berhasil di-resolve, timestamp dan note tersimpan") \
        .flow(
            "service.mark_alert_reviewed(alert_id, note) → "
            "get alert → check not resolved → repo.resolve() → return updated"
        )

    # Setup
    original_alert = MagicMock(id=1, resolved=False)
    resolved_alert = MagicMock(id=1, resolved=True, resolved_note="False alarm")
    mock_alert_repo.get_by_id.return_value = original_alert
    mock_alert_repo.resolve.return_value = resolved_alert

    # Execute
    result = await service.mark_alert_reviewed(alert_id=1, resolved_note="False alarm")

    # Assert
    assert result.resolved is True
    mock_alert_repo.resolve.assert_awaited_once_with(original_alert, note="False alarm")
    test_reporter.result("Alert 1 marked as resolved with note 'False alarm'")


@pytest.mark.asyncio
async def test_mark_alert_reviewed_not_found(test_reporter, service, mock_alert_repo):
    """Alert ID tidak ada — raise NotFoundException."""
    test_reporter \
        .scenario("Alert ID tidak ada di database") \
        .goal("Service raise NotFoundException") \
        .flow(
            "service.mark_alert_reviewed(invalid_id) → "
            "alert_repo.get_by_id() return None → raise NotFoundException"
        )

    # Setup
    mock_alert_repo.get_by_id.return_value = None

    # Execute & Assert
    with pytest.raises(NotFoundException):
        await service.mark_alert_reviewed(alert_id=9999)

    test_reporter.result("NotFoundException raised untuk alert tidak ditemukan")


@pytest.mark.asyncio
async def test_mark_alert_reviewed_already_resolved(
    test_reporter,
    service,
    mock_alert_repo,
):
    """Alert sudah di-resolve — raise ValidationException."""
    test_reporter \
        .scenario("Alert sudah di-resolve sebelumnya") \
        .goal("Service raise ValidationException, tidak update lagi") \
        .flow(
            "service.mark_alert_reviewed(already_resolved_alert) → "
            "check alert.resolved → raise ValidationException"
        )

    # Setup
    already_resolved = MagicMock(id=1, resolved=True)
    mock_alert_repo.get_by_id.return_value = already_resolved

    # Execute & Assert
    with pytest.raises(ValidationException):
        await service.mark_alert_reviewed(alert_id=1)

    test_reporter.result("ValidationException raised, alert sudah resolved")
