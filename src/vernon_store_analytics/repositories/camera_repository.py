"""Repository untuk operasi database Camera."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.db.camera import Camera


class CameraRepository:
    """Data access layer untuk Camera entity."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_store(self, store_id: int) -> list[Camera]:
        """Mendapatkan semua camera untuk store tertentu."""
        result = await self.db.execute(
            select(Camera).where(Camera.store_id == store_id).order_by(Camera.created_at.desc())
        )
        return list(result.scalars().all())

    async def get_by_id(self, camera_id: int) -> Camera | None:
        """Mendapatkan camera berdasarkan ID."""
        result = await self.db.execute(select(Camera).where(Camera.id == camera_id))
        return result.scalar_one_or_none()

    async def create(self, camera: Camera) -> Camera:
        """Membuat camera baru."""
        self.db.add(camera)
        await self.db.flush()
        await self.db.refresh(camera)
        return camera

    async def update(self, camera: Camera) -> Camera:
        """Update camera."""
        await self.db.flush()
        await self.db.refresh(camera)
        return camera

    async def delete(self, camera: Camera) -> None:
        """Hapus camera."""
        await self.db.delete(camera)
        await self.db.flush()
