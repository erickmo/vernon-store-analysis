"""API routes untuk Traffic analytics."""

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...models.response.traffic_response import (
    RealtimeTrafficResponse,
    TrafficSnapshotResponse,
    TrafficSummaryResponse,
)
from ...repositories.store_repository import StoreRepository
from ...repositories.traffic_repository import TrafficRepository
from ...repositories.visit_repository import VisitRepository
from ...services.traffic_service import TrafficService
from .dependencies import get_current_user

router = APIRouter(prefix="/stores/{store_id}/traffic", tags=["traffic"])


def _get_service(db: AsyncSession = Depends(get_db)) -> TrafficService:
    return TrafficService(TrafficRepository(db), StoreRepository(db), VisitRepository(db))


@router.get("", response_model=TrafficSummaryResponse)
async def get_traffic_summary(
    store_id: int,
    start: datetime | None = Query(None, description="Period start (ISO format)"),
    end: datetime | None = Query(None, description="Period end (ISO format)"),
    service: TrafficService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Mendapatkan ringkasan traffic untuk store. Default: 24 jam terakhir."""
    now = datetime.now(timezone.utc)
    if not end:
        end = now
    if not start:
        start = now - timedelta(hours=24)
    result = await service.get_traffic_summary(store_id, start, end)
    return TrafficSummaryResponse(
        store_id=result["store_id"],
        period_start=result["period_start"],
        period_end=result["period_end"],
        total_visitors=result["total_visitors"],
        avg_dwell_seconds=result["avg_dwell_seconds"],
        peak_visitor_count=result["peak_visitor_count"],
        snapshots=[TrafficSnapshotResponse.model_validate(s) for s in result["snapshots"]],
    )


@router.get("/realtime", response_model=RealtimeTrafficResponse)
async def get_realtime_traffic(
    store_id: int,
    service: TrafficService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Mendapatkan jumlah visitor yang sedang ada di store saat ini."""
    result = await service.get_realtime_count(store_id)
    return RealtimeTrafficResponse(**result)
