"""Repository untuk operasi database TrafficSnapshot."""

from datetime import datetime

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.db.traffic_snapshot import TrafficSnapshot


class TrafficRepository:
    """Data access layer untuk TrafficSnapshot entity."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_store_period(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[TrafficSnapshot]:
        """Mendapatkan traffic snapshots untuk store dalam periode waktu."""
        result = await self.db.execute(
            select(TrafficSnapshot)
            .where(
                TrafficSnapshot.store_id == store_id,
                TrafficSnapshot.timestamp >= start,
                TrafficSnapshot.timestamp <= end,
            )
            .order_by(TrafficSnapshot.timestamp.asc())
        )
        return list(result.scalars().all())

    async def get_summary(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """Mendapatkan ringkasan traffic untuk periode tertentu."""
        result = await self.db.execute(
            select(
                func.sum(TrafficSnapshot.visitor_count).label("total_visitors"),
                func.avg(TrafficSnapshot.avg_dwell_seconds).label("avg_dwell"),
                func.max(TrafficSnapshot.peak_count).label("peak_count"),
            )
            .where(
                TrafficSnapshot.store_id == store_id,
                TrafficSnapshot.timestamp >= start,
                TrafficSnapshot.timestamp <= end,
            )
        )
        row = result.one()
        return {
            "total_visitors": row.total_visitors or 0,
            "avg_dwell_seconds": float(row.avg_dwell) if row.avg_dwell else None,
            "peak_visitor_count": row.peak_count,
        }

    async def create(self, snapshot: TrafficSnapshot) -> TrafficSnapshot:
        """Membuat traffic snapshot baru."""
        self.db.add(snapshot)
        await self.db.flush()
        await self.db.refresh(snapshot)
        return snapshot
