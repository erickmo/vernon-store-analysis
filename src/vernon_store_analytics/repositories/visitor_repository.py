"""Repository untuk operasi database Visitor."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.db.visitor import Visitor


class VisitorRepository:
    """Data access layer untuk Visitor entity."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_store(self, store_id: int, limit: int = 50, offset: int = 0) -> list[Visitor]:
        """Mendapatkan visitors untuk store tertentu."""
        result = await self.db.execute(
            select(Visitor)
            .where(Visitor.store_id == store_id)
            .order_by(Visitor.last_seen_at.desc())
            .limit(limit)
            .offset(offset)
        )
        return list(result.scalars().all())

    async def get_by_id(self, visitor_id: int) -> Visitor | None:
        """Mendapatkan visitor berdasarkan ID."""
        result = await self.db.execute(select(Visitor).where(Visitor.id == visitor_id))
        return result.scalar_one_or_none()

    async def get_by_person_uid(self, person_uid: str) -> Visitor | None:
        """Mendapatkan visitor berdasarkan person_uid."""
        result = await self.db.execute(
            select(Visitor).where(Visitor.person_uid == person_uid)
        )
        return result.scalar_one_or_none()

    async def create(self, visitor: Visitor) -> Visitor:
        """Membuat visitor baru."""
        self.db.add(visitor)
        await self.db.flush()
        await self.db.refresh(visitor)
        return visitor

    async def update(self, visitor: Visitor) -> Visitor:
        """Update visitor."""
        await self.db.flush()
        await self.db.refresh(visitor)
        return visitor

    async def count_by_store(self, store_id: int) -> int:
        """Menghitung jumlah visitor untuk store tertentu."""
        from sqlalchemy import func
        result = await self.db.execute(
            select(func.count()).select_from(Visitor).where(Visitor.store_id == store_id)
        )
        return result.scalar_one()
