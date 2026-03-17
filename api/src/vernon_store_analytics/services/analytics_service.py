"""Business logic untuk Store Analytics — aggregasi semua statistik."""

from datetime import datetime, timedelta, timezone

import structlog

from ..core.exceptions import NotFoundException
from ..repositories.analytics_repository import AnalyticsRepository
from ..repositories.store_repository import StoreRepository

logger = structlog.get_logger(__name__)


class AnalyticsService:
    """Service layer untuk analytics dan statistik pengunjung."""

    def __init__(
        self,
        analytics_repo: AnalyticsRepository,
        store_repo: StoreRepository,
    ) -> None:
        self.analytics_repo = analytics_repo
        self.store_repo = store_repo

    async def _validate_store(self, store_id: int) -> None:
        """Validasi store exists."""
        store = await self.store_repo.get_by_id(store_id)
        if not store:
            raise NotFoundException("Store")

    async def get_dashboard(
        self, store_id: int, start: datetime | None = None, end: datetime | None = None
    ) -> dict:
        """
        Mendapatkan semua statistik untuk dashboard.
        Default: 24 jam terakhir.
        """
        await self._validate_store(store_id)

        now = datetime.now(timezone.utc)
        if not end:
            end = now
        if not start:
            start = now - timedelta(hours=24)

        visitor_count = await self.analytics_repo.get_visitor_count(store_id, start, end)
        gender_stats = await self.analytics_repo.get_gender_stats(store_id, start, end)
        age_stats = await self.analytics_repo.get_age_stats(store_id, start, end)
        mood_stats = await self.analytics_repo.get_all_zone_mood_stats(store_id, start, end)
        dwell_stats = await self.analytics_repo.get_dwell_time_stats(store_id, start, end)
        dwell_distribution = await self.analytics_repo.get_dwell_time_distribution(store_id, start, end)
        hourly = await self.analytics_repo.get_hourly_traffic(store_id, start, end)

        return {
            "store_id": store_id,
            "period": {
                "start": start.isoformat(),
                "end": end.isoformat(),
            },
            "summary": {
                "total_visitors": visitor_count,
                "avg_dwell_minutes": dwell_stats["avg_dwell_minutes"],
                "max_dwell_minutes": round(dwell_stats["max_dwell_seconds"] / 60, 1) if dwell_stats["max_dwell_seconds"] else 0,
            },
            "gender": gender_stats,
            "age_groups": age_stats,
            "mood": {
                "entry": mood_stats["entry"],
                "exit": mood_stats["exit"],
                "cashier": mood_stats["cashier"],
                "floor": mood_stats["floor"],
            },
            "dwell_time": dwell_stats,
            "dwell_distribution": dwell_distribution,
            "hourly_traffic": hourly,
        }

    async def get_gender_stats(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """Statistik gender pengunjung."""
        await self._validate_store(store_id)
        stats = await self.analytics_repo.get_gender_stats(store_id, start, end)
        return {"store_id": store_id, "period": {"start": start.isoformat(), "end": end.isoformat()}, "gender": stats}

    async def get_age_stats(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """Statistik usia pengunjung."""
        await self._validate_store(store_id)
        stats = await self.analytics_repo.get_age_stats(store_id, start, end)
        return {"store_id": store_id, "period": {"start": start.isoformat(), "end": end.isoformat()}, "age_groups": stats}

    async def get_mood_stats(
        self, store_id: int, start: datetime, end: datetime, zone: str | None = None
    ) -> dict:
        """Statistik mood pengunjung, opsional filter per zone."""
        await self._validate_store(store_id)
        if zone:
            stats = await self.analytics_repo.get_mood_stats_by_zone(store_id, start, end, zone)
            return {"store_id": store_id, "zone": zone, "mood": stats}
        stats = await self.analytics_repo.get_all_zone_mood_stats(store_id, start, end)
        return {"store_id": store_id, "mood": stats}

    async def get_dwell_stats(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """Statistik dwell time."""
        await self._validate_store(store_id)
        stats = await self.analytics_repo.get_dwell_time_stats(store_id, start, end)
        distribution = await self.analytics_repo.get_dwell_time_distribution(store_id, start, end)
        return {
            "store_id": store_id,
            "period": {"start": start.isoformat(), "end": end.isoformat()},
            "dwell_time": stats,
            "distribution": distribution,
        }

    async def get_visitor_details(
        self,
        store_id: int,
        start: datetime,
        end: datetime,
        limit: int = 50,
        offset: int = 0,
    ) -> dict:
        """Detail list pengunjung dengan demographics dan mood."""
        await self._validate_store(store_id)
        visitors = await self.analytics_repo.get_visitor_details_list(
            store_id, start, end, limit=limit, offset=offset
        )
        total = await self.analytics_repo.get_visitor_count(store_id, start, end)
        return {
            "store_id": store_id,
            "period": {"start": start.isoformat(), "end": end.isoformat()},
            "total": total,
            "data": visitors,
        }
