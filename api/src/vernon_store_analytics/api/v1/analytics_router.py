"""API routes untuk Store Analytics — statistik pengunjung, gender, usia, mood, dwell time."""

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...repositories.analytics_repository import AnalyticsRepository
from ...repositories.store_repository import StoreRepository
from ...services.analytics_service import AnalyticsService
from .dependencies import get_current_user

router = APIRouter(prefix="/stores/{store_id}/analytics", tags=["analytics"])


def _get_service(db: AsyncSession = Depends(get_db)) -> AnalyticsService:
    return AnalyticsService(AnalyticsRepository(db), StoreRepository(db))


def _parse_period(
    start: datetime | None, end: datetime | None
) -> tuple[datetime, datetime]:
    """Parse period start/end, default 24 jam terakhir."""
    now = datetime.now(timezone.utc)
    return start or (now - timedelta(hours=24)), end or now


@router.get("/dashboard")
async def get_dashboard(
    store_id: int,
    start: datetime | None = Query(None, description="Period start (ISO format)"),
    end: datetime | None = Query(None, description="Period end (ISO format)"),
    service: AnalyticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """
    Dashboard lengkap — semua statistik dalam satu endpoint.
    Termasuk: visitor count, gender, age, mood (entry/exit/cashier), dwell time, hourly traffic.
    Default period: 24 jam terakhir.
    """
    start, end = _parse_period(start, end)
    return await service.get_dashboard(store_id, start, end)


@router.get("/gender")
async def get_gender_stats(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: AnalyticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Statistik gender pengunjung."""
    start, end = _parse_period(start, end)
    return await service.get_gender_stats(store_id, start, end)


@router.get("/age")
async def get_age_stats(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: AnalyticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Statistik perkiraan usia dan age group pengunjung."""
    start, end = _parse_period(start, end)
    return await service.get_age_stats(store_id, start, end)


@router.get("/mood")
async def get_mood_stats(
    store_id: int,
    zone: str | None = Query(None, description="Filter zone: entry, exit, cashier, floor"),
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: AnalyticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """
    Statistik mood pengunjung per zone.
    Zone: entry (datang), exit (pulang), cashier (kasir), floor (area umum).
    Tanpa filter zone: return semua zone sekaligus.
    """
    start, end = _parse_period(start, end)
    return await service.get_mood_stats(store_id, start, end, zone=zone)


@router.get("/dwell-time")
async def get_dwell_time_stats(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: AnalyticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Statistik berapa lama seseorang di dalam store (dwell time)."""
    start, end = _parse_period(start, end)
    return await service.get_dwell_stats(store_id, start, end)


@router.get("/visitors")
async def get_visitor_details(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    service: AnalyticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """
    Detail list pengunjung dengan demographics lengkap:
    gender, usia, mood saat entry/exit/cashier, dwell time.
    """
    start, end = _parse_period(start, end)
    return await service.get_visitor_details(store_id, start, end, limit=limit, offset=offset)
