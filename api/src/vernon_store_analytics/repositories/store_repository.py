"""Repository untuk operasi database Store."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.db.store import Store


class StoreRepository:
    """Data access layer untuk Store entity."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_all(self) -> list[Store]:
        """Mendapatkan semua store."""
        result = await self.db.execute(select(Store).order_by(Store.created_at.desc()))
        return list(result.scalars().all())

    async def get_by_id(self, store_id: int) -> Store | None:
        """Mendapatkan store berdasarkan ID."""
        result = await self.db.execute(select(Store).where(Store.id == store_id))
        return result.scalar_one_or_none()

    async def create(self, store: Store) -> Store:
        """Membuat store baru."""
        self.db.add(store)
        await self.db.flush()
        await self.db.refresh(store)
        return store

    async def update(self, store: Store) -> Store:
        """Update store yang sudah ada."""
        await self.db.flush()
        await self.db.refresh(store)
        return store

    async def delete(self, store: Store) -> None:
        """Hapus store."""
        await self.db.delete(store)
        await self.db.flush()
