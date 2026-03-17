"""SQLAlchemy model untuk Camera."""

from datetime import datetime, timezone

from sqlalchemy import DateTime, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ...core.database import Base


class Camera(Base):
    """CCTV camera yang terdaftar di store."""

    __tablename__ = "cameras"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    store_id: Mapped[int] = mapped_column(ForeignKey("stores.id"), nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    stream_url: Mapped[str] = mapped_column(String(1000), nullable=False)
    location_zone: Mapped[str] = mapped_column(String(255), nullable=False)
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
    store = relationship("Store", back_populates="cameras")
    visits = relationship("Visit", back_populates="camera", lazy="selectin")
    shoplifting_alerts = relationship("ShopliftingAlert", back_populates="camera", lazy="selectin")
