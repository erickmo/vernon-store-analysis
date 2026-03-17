"""API routes untuk Shoplifting Alert."""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...models.request.alert_request import AlertResolveRequest
from ...models.response.alert_response import AlertListResponse, AlertResponse
from ...repositories.alert_repository import AlertRepository
from ...repositories.store_repository import StoreRepository
from ...services.alert_service import AlertService
from .dependencies import get_current_user

router = APIRouter(tags=["alerts"])


def _get_service(db: AsyncSession = Depends(get_db)) -> AlertService:
    return AlertService(AlertRepository(db), StoreRepository(db))


@router.get("/stores/{store_id}/alerts", response_model=AlertListResponse)
async def list_alerts(
    store_id: int,
    resolved: bool | None = Query(None, description="Filter by resolved status"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    service: AlertService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Mendapatkan daftar shoplifting alerts untuk store."""
    alerts = await service.list_alerts(store_id, resolved=resolved, limit=limit, offset=offset)
    return AlertListResponse(
        data=[AlertResponse.model_validate(a) for a in alerts],
        total=len(alerts),
    )


@router.put("/alerts/{alert_id}/resolve", response_model=AlertResponse)
async def resolve_alert(
    alert_id: int,
    data: AlertResolveRequest,
    service: AlertService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Resolve shoplifting alert."""
    alert = await service.resolve_alert(alert_id, data)
    return AlertResponse.model_validate(alert)
