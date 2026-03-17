"""SQLAlchemy model untuk TrafficSnapshot."""

from datetime import datetime, timezone

from sqlalchemy import DateTime, Float, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ...core.database import Base


class TrafficSnapshot(Base):
    """Agregasi traffic per interval waktu."""

    __tablename__ = "traffic_snapshots"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    store_id: Mapped[int] = mapped_column(ForeignKey("stores.id"), nullable=False)
    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    visitor_count: Mapped[int] = mapped_column(Integer, default=0)
    avg_dwell_seconds: Mapped[float | None] = mapped_column(Float, nullable=True)
    peak_count: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    # Relationships
    store = relationship("Store", back_populates="traffic_snapshots")
