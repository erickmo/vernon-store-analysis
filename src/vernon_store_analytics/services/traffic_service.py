"""Business logic untuk Traffic analytics."""

from datetime import datetime, timezone

import structlog

from ..core.exceptions import NotFoundException
from ..repositories.store_repository import StoreRepository
from ..repositories.traffic_repository import TrafficRepository
from ..repositories.visit_repository import VisitRepository

logger = structlog.get_logger(__name__)


class TrafficService:
    """Service layer untuk traffic analytics."""

    def __init__(
        self,
        traffic_repo: TrafficRepository,
        store_repo: StoreRepository,
        visit_repo: VisitRepository,
    ) -> None:
        self.traffic_repo = traffic_repo
        self.store_repo = store_repo
        self.visit_repo = visit_repo

    async def get_traffic_summary(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """Mendapatkan ringkasan traffic untuk periode tertentu."""
        store = await self.store_repo.get_by_id(store_id)
        if not store:
            raise NotFoundException("Store")

        summary = await self.traffic_repo.get_summary(store_id, start, end)
        snapshots = await self.traffic_repo.get_by_store_period(store_id, start, end)

        return {
            "store_id": store_id,
            "period_start": start,
            "period_end": end,
            **summary,
            "snapshots": snapshots,
        }

    async def get_realtime_count(self, store_id: int) -> dict:
        """Mendapatkan jumlah visitor yang sedang ada di store saat ini."""
        store = await self.store_repo.get_by_id(store_id)
        if not store:
            raise NotFoundException("Store")

        active_visits = await self.visit_repo.get_active_visits(store_id)
        return {
            "store_id": store_id,
            "current_visitor_count": len(active_visits),
            "timestamp": datetime.now(timezone.utc),
        }
