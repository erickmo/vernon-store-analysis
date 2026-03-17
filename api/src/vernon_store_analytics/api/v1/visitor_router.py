"""API routes untuk Visitor dan mood timeline."""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...models.response.visitor_response import (
    MoodLogResponse,
    MoodTimelineResponse,
    VisitResponse,
    VisitorDetailResponse,
    VisitorListResponse,
    VisitorResponse,
)
from ...repositories.mood_log_repository import MoodLogRepository
from ...repositories.visit_repository import VisitRepository
from ...repositories.visitor_repository import VisitorRepository
from ...services.visitor_service import VisitorService
from .dependencies import get_current_user

router = APIRouter(tags=["visitors"])


def _get_service(db: AsyncSession = Depends(get_db)) -> VisitorService:
    return VisitorService(VisitorRepository(db), VisitRepository(db), MoodLogRepository(db))


@router.get("/stores/{store_id}/visitors", response_model=VisitorListResponse)
async def list_visitors(
    store_id: int,
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    service: VisitorService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Mendapatkan daftar visitor yang terdeteksi di store."""
    visitors, total = await service.list_visitors(store_id, limit=limit, offset=offset)
    return VisitorListResponse(
        data=[VisitorResponse.model_validate(v) for v in visitors],
        total=total,
    )


@router.get("/visitors/{visitor_id}", response_model=VisitorDetailResponse)
async def get_visitor(
    visitor_id: int,
    service: VisitorService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Mendapatkan detail visitor dengan visit history."""
    visitor = await service.get_visitor(visitor_id)
    visits = await service.get_visitor_visits(visitor_id)
    return VisitorDetailResponse(
        data=VisitorResponse.model_validate(visitor),
        visits=[VisitResponse.model_validate(v) for v in visits],
    )


@router.get("/visitors/{visitor_id}/visits/{visit_id}/mood-timeline", response_model=MoodTimelineResponse)
async def get_mood_timeline(
    visitor_id: int,
    visit_id: int,
    service: VisitorService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Mendapatkan mood timeline untuk visit tertentu."""
    mood_logs = await service.get_mood_timeline(visitor_id, visit_id)
    return MoodTimelineResponse(
        data=[MoodLogResponse.model_validate(m) for m in mood_logs],
    )
