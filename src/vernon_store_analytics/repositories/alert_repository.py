"""Repository untuk operasi database ShopliftingAlert."""

from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.db.shoplifting_alert import ShopliftingAlert


class AlertRepository:
    """Data access layer untuk ShopliftingAlert entity."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_store(
        self, store_id: int, resolved: bool | None = None, limit: int = 50, offset: int = 0
    ) -> list[ShopliftingAlert]:
        """Mendapatkan alerts untuk store tertentu."""
        from ..models.db.camera import Camera
        query = (
            select(ShopliftingAlert)
            .join(Camera, ShopliftingAlert.camera_id == Camera.id)
            .where(Camera.store_id == store_id)
        )
        if resolved is not None:
            query = query.where(ShopliftingAlert.resolved == resolved)
        query = query.order_by(ShopliftingAlert.timestamp.desc()).limit(limit).offset(offset)
        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def get_by_id(self, alert_id: int) -> ShopliftingAlert | None:
        """Mendapatkan alert berdasarkan ID."""
        result = await self.db.execute(
            select(ShopliftingAlert).where(ShopliftingAlert.id == alert_id)
        )
        return result.scalar_one_or_none()

    async def create(self, alert: ShopliftingAlert) -> ShopliftingAlert:
        """Membuat alert baru."""
        self.db.add(alert)
        await self.db.flush()
        await self.db.refresh(alert)
        return alert

    async def resolve(self, alert: ShopliftingAlert, note: str | None = None) -> ShopliftingAlert:
        """Resolve alert."""
        alert.resolved = True
        alert.resolved_at = datetime.now(timezone.utc)
        alert.resolved_note = note
        await self.db.flush()
        await self.db.refresh(alert)
        return alert
