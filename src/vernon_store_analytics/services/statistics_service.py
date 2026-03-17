"""Business logic untuk Store Statistics dan Customer Behavior."""

from datetime import datetime, timedelta, timezone

import structlog

from ..core.exceptions import NotFoundException
from ..repositories.statistics_repository import StatisticsRepository
from ..repositories.store_repository import StoreRepository

logger = structlog.get_logger(__name__)


class StatisticsService:
    """Service layer untuk advanced store statistics dan customer behavior."""

    def __init__(
        self,
        stats_repo: StatisticsRepository,
        store_repo: StoreRepository,
    ) -> None:
        self.stats_repo = stats_repo
        self.store_repo = store_repo

    async def _validate_store(self, store_id: int) -> None:
        store = await self.store_repo.get_by_id(store_id)
        if not store:
            raise NotFoundException("Store")

    async def get_store_kpi(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """
        KPI utama store dalam satu endpoint:
        conversion rate, bounce rate, return rate, satisfaction score.
        """
        await self._validate_store(store_id)

        conversion = await self.stats_repo.get_conversion_rate(store_id, start, end)
        bounce = await self.stats_repo.get_bounce_rate(store_id, start, end)
        returning = await self.stats_repo.get_return_visitor_stats(store_id, start, end)
        mood_shift = await self.stats_repo.get_mood_shift(store_id, start, end)

        return {
            "store_id": store_id,
            "period": {"start": start.isoformat(), "end": end.isoformat()},
            "kpi": {
                "total_visitors": conversion["total_visitors"],
                "conversion_rate": conversion["conversion_rate"],
                "bounce_rate": bounce["bounce_rate"],
                "return_visitor_rate": returning["return_rate"],
                "satisfaction_score": mood_shift["satisfaction_score"],
            },
            "conversion": conversion,
            "bounce": bounce,
            "return_visitors": returning,
            "mood_shift_summary": {
                "improved": mood_shift["improved_rate"],
                "worsened": mood_shift["worsened_rate"],
                "same": round(100 - mood_shift["improved_rate"] - mood_shift["worsened_rate"], 1),
            },
        }

    async def get_customer_behavior(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """
        Analisis customer behavior lengkap:
        zone flow, mood shift, demographics x dwell, peak hours.
        """
        await self._validate_store(store_id)

        zone_flow = await self.stats_repo.get_zone_flow(store_id, start, end)
        mood_shift = await self.stats_repo.get_mood_shift(store_id, start, end)
        demographics = await self.stats_repo.get_demographics_crosstab(store_id, start, end)
        dwell_gender = await self.stats_repo.get_dwell_by_gender(store_id, start, end)
        dwell_age = await self.stats_repo.get_dwell_by_age_group(store_id, start, end)
        zone_heatmap = await self.stats_repo.get_zone_heatmap(store_id, start, end)
        peak_hours = await self.stats_repo.get_peak_hours(store_id, start, end)
        cashier_mood = await self.stats_repo.get_cashier_mood_by_demographics(store_id, start, end)

        return {
            "store_id": store_id,
            "period": {"start": start.isoformat(), "end": end.isoformat()},
            "customer_journey": zone_flow,
            "mood_shift": mood_shift,
            "demographics_crosstab": demographics,
            "dwell_by_gender": dwell_gender,
            "dwell_by_age_group": dwell_age,
            "zone_heatmap": zone_heatmap,
            "peak_hours": peak_hours,
            "cashier_mood_by_gender": cashier_mood,
        }

    async def get_conversion_stats(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        await self._validate_store(store_id)
        return await self.stats_repo.get_conversion_rate(store_id, start, end)

    async def get_bounce_stats(
        self, store_id: int, start: datetime, end: datetime, threshold: int = 120
    ) -> dict:
        await self._validate_store(store_id)
        return await self.stats_repo.get_bounce_rate(store_id, start, end, threshold)

    async def get_return_stats(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        await self._validate_store(store_id)
        return await self.stats_repo.get_return_visitor_stats(store_id, start, end)

    async def get_zone_flow(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        await self._validate_store(store_id)
        return await self.stats_repo.get_zone_flow(store_id, start, end)

    async def get_mood_shift(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        await self._validate_store(store_id)
        return await self.stats_repo.get_mood_shift(store_id, start, end)

    async def get_demographics(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        await self._validate_store(store_id)
        crosstab = await self.stats_repo.get_demographics_crosstab(store_id, start, end)
        dwell_gender = await self.stats_repo.get_dwell_by_gender(store_id, start, end)
        dwell_age = await self.stats_repo.get_dwell_by_age_group(store_id, start, end)
        return {
            "store_id": store_id,
            "demographics_crosstab": crosstab,
            "dwell_by_gender": dwell_gender,
            "dwell_by_age_group": dwell_age,
        }

    async def get_zone_heatmap(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        await self._validate_store(store_id)
        return await self.stats_repo.get_zone_heatmap(store_id, start, end)

    async def get_peak_hours(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        await self._validate_store(store_id)
        return await self.stats_repo.get_peak_hours(store_id, start, end)
