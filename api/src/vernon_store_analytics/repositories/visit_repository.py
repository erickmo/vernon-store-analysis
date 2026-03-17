"""Repository untuk operasi database Visit."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.db.visit import Visit


class VisitRepository:
    """Data access layer untuk Visit entity."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_visitor(self, visitor_id: int) -> list[Visit]:
        """Mendapatkan semua visit untuk visitor tertentu."""
        result = await self.db.execute(
            select(Visit).where(Visit.visitor_id == visitor_id).order_by(Visit.entry_at.desc())
        )
        return list(result.scalars().all())

    async def get_by_id(self, visit_id: int) -> Visit | None:
        """Mendapatkan visit berdasarkan ID."""
        result = await self.db.execute(select(Visit).where(Visit.id == visit_id))
        return result.scalar_one_or_none()

    async def get_active_visits(self, store_id: int) -> list[Visit]:
        """Mendapatkan visit yang masih aktif (belum exit) di store."""
        from ..models.db.visitor import Visitor
        result = await self.db.execute(
            select(Visit)
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(Visitor.store_id == store_id, Visit.exit_at.is_(None))
        )
        return list(result.scalars().all())

    async def create(self, visit: Visit) -> Visit:
        """Membuat visit baru."""
        self.db.add(visit)
        await self.db.flush()
        await self.db.refresh(visit)
        return visit

    async def update(self, visit: Visit) -> Visit:
        """Update visit."""
        await self.db.flush()
        await self.db.refresh(visit)
        return visit
