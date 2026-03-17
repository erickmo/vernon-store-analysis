"""Repository untuk operasi database MoodLog."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.db.mood_log import MoodLog


class MoodLogRepository:
    """Data access layer untuk MoodLog entity."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_visit(self, visit_id: int) -> list[MoodLog]:
        """Mendapatkan mood logs untuk visit tertentu, urut berdasarkan waktu."""
        result = await self.db.execute(
            select(MoodLog)
            .where(MoodLog.visit_id == visit_id)
            .order_by(MoodLog.timestamp.asc())
        )
        return list(result.scalars().all())

    async def create(self, mood_log: MoodLog) -> MoodLog:
        """Membuat mood log baru."""
        self.db.add(mood_log)
        await self.db.flush()
        await self.db.refresh(mood_log)
        return mood_log

    async def create_batch(self, mood_logs: list[MoodLog]) -> list[MoodLog]:
        """Membuat beberapa mood log sekaligus."""
        self.db.add_all(mood_logs)
        await self.db.flush()
        for log in mood_logs:
            await self.db.refresh(log)
        return mood_logs
