"""
API routes untuk Store Statistics dan Customer Behavior Analytics.

Endpoint group:
- /kpi          — KPI utama (conversion, bounce, return, satisfaction)
- /behavior     — Customer behavior lengkap (journey, mood shift, demographics)
- /conversion   — Conversion rate detail
- /bounce       — Bounce rate detail
- /return       — Return visitor stats
- /journey      — Customer journey / zone flow
- /mood-shift   — Mood entry vs exit analysis
- /demographics — Gender x Age cross-tab + dwell time
- /heatmap      — Zone heatmap data
- /peak-hours   — Peak hours analysis
"""

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...repositories.statistics_repository import StatisticsRepository
from ...repositories.store_repository import StoreRepository
from ...services.statistics_service import StatisticsService
from .dependencies import get_current_user

router = APIRouter(prefix="/stores/{store_id}/statistics", tags=["statistics"])


def _get_service(db: AsyncSession = Depends(get_db)) -> StatisticsService:
    return StatisticsService(StatisticsRepository(db), StoreRepository(db))


def _parse_period(
    start: datetime | None, end: datetime | None
) -> tuple[datetime, datetime]:
    now = datetime.now(timezone.utc)
    return start or (now - timedelta(hours=24)), end or now


@router.get("/kpi")
async def get_store_kpi(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: StatisticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """
    KPI utama store: conversion rate, bounce rate, return visitor rate, satisfaction score.
    Semua dalam satu endpoint.
    """
    start, end = _parse_period(start, end)
    return await service.get_store_kpi(store_id, start, end)


@router.get("/behavior")
async def get_customer_behavior(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: StatisticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """
    Analisis customer behavior lengkap:
    journey patterns, mood shift, demographics breakdown, zone heatmap, peak hours.
    """
    start, end = _parse_period(start, end)
    return await service.get_customer_behavior(store_id, start, end)


@router.get("/conversion")
async def get_conversion_rate(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: StatisticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Conversion rate — berapa persen pengunjung yang ke kasir."""
    start, end = _parse_period(start, end)
    return await service.get_conversion_stats(store_id, start, end)


@router.get("/bounce")
async def get_bounce_rate(
    store_id: int,
    threshold_seconds: int = Query(120, description="Bounce threshold dalam detik (default 2 menit)"),
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: StatisticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Bounce rate — berapa persen pengunjung yang langsung pergi (< threshold)."""
    start, end = _parse_period(start, end)
    return await service.get_bounce_stats(store_id, start, end, threshold_seconds)


@router.get("/return-visitors")
async def get_return_visitors(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: StatisticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Return visitor rate — new vs returning visitors."""
    start, end = _parse_period(start, end)
    return await service.get_return_stats(store_id, start, end)


@router.get("/journey")
async def get_customer_journey(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: StatisticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """
    Customer journey — pola perjalanan pengunjung di store.
    Contoh: entry → floor → cashier → exit (56%), entry → floor → exit (30%).
    """
    start, end = _parse_period(start, end)
    return await service.get_zone_flow(store_id, start, end)


@router.get("/mood-shift")
async def get_mood_shift(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: StatisticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """
    Mood shift analysis — perubahan mood dari masuk ke keluar store.
    Termasuk: improved/worsened/same rate, satisfaction score, top transitions.
    """
    start, end = _parse_period(start, end)
    return await service.get_mood_shift(store_id, start, end)


@router.get("/demographics")
async def get_demographics(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: StatisticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Demographics breakdown — gender x age crosstab, dwell time per gender & age group."""
    start, end = _parse_period(start, end)
    return await service.get_demographics(store_id, start, end)


@router.get("/heatmap")
async def get_zone_heatmap(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: StatisticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Zone heatmap — traffic share per zona store."""
    start, end = _parse_period(start, end)
    return await service.get_zone_heatmap(store_id, start, end)


@router.get("/peak-hours")
async def get_peak_hours(
    store_id: int,
    start: datetime | None = Query(None),
    end: datetime | None = Query(None),
    service: StatisticsService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Peak hours analysis — jam tersibuk dan tersepi."""
    start, end = _parse_period(start, end)
    return await service.get_peak_hours(store_id, start, end)
