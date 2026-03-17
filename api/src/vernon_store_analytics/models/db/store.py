"""SQLAlchemy model untuk Store."""

from datetime import datetime, timezone

from sqlalchemy import DateTime, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ...core.database import Base


class Store(Base):
    """Informasi store yang dimonitor."""

    __tablename__ = "stores"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    location: Mapped[str] = mapped_column(String(500), nullable=False)
    timezone: Mapped[str] = mapped_column(String(50), default="Asia/Jakarta")
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_active: Mapped[bool] = mapped_column(default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    # Relationships
    cameras = relationship("Camera", back_populates="store", lazy="selectin")
    visitors = relationship("Visitor", back_populates="store", lazy="selectin")
    traffic_snapshots = relationship("TrafficSnapshot", back_populates="store", lazy="selectin")
