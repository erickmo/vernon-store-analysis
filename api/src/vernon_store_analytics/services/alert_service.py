"""Business logic untuk Shoplifting Alert."""

import structlog

from ..core.exceptions import NotFoundException, ValidationException
from ..models.db.shoplifting_alert import ShopliftingAlert
from ..models.request.alert_request import AlertResolveRequest
from ..repositories.alert_repository import AlertRepository
from ..repositories.store_repository import StoreRepository

logger = structlog.get_logger(__name__)


class AlertService:
    """Service layer untuk operasi ShopliftingAlert."""

    def __init__(self, alert_repo: AlertRepository, store_repo: StoreRepository) -> None:
        self.alert_repo = alert_repo
        self.store_repo = store_repo

    async def list_alerts(
        self,
        store_id: int,
        resolved: bool | None = None,
        limit: int = 50,
        offset: int = 0,
    ) -> list[ShopliftingAlert]:
        """Mendapatkan alerts untuk store tertentu."""
        store = await self.store_repo.get_by_id(store_id)
        if not store:
            raise NotFoundException("Store")
        return await self.alert_repo.get_by_store(store_id, resolved=resolved, limit=limit, offset=offset)

    async def get_alert(self, alert_id: int) -> ShopliftingAlert:
        """Mendapatkan alert berdasarkan ID."""
        alert = await self.alert_repo.get_by_id(alert_id)
        if not alert:
            raise NotFoundException("Alert")
        return alert

    async def resolve_alert(self, alert_id: int, data: AlertResolveRequest) -> ShopliftingAlert:
        """Resolve shoplifting alert."""
        alert = await self.get_alert(alert_id)
        if alert.resolved:
            raise ValidationException("Alert sudah di-resolve sebelumnya")
        alert = await self.alert_repo.resolve(alert, note=data.resolved_note)
        logger.info("alert resolved", alert_id=alert.id)
        return alert
