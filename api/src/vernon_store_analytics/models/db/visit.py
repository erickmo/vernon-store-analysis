"""SQLAlchemy model untuk Visit."""

from datetime import datetime, timezone

from sqlalchemy import DateTime, Float, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ...core.database import Base


class Visit(Base):
    """Satu kunjungan visitor ke store."""

    __tablename__ = "visits"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    visitor_id: Mapped[int] = mapped_column(ForeignKey("visitors.id"), nullable=False)
    camera_id: Mapped[int] = mapped_column(ForeignKey("cameras.id"), nullable=False)
    entry_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    exit_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    dwell_seconds: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    # Relationships
    visitor = relationship("Visitor", back_populates="visits")
    camera = relationship("Camera", back_populates="visits")
    mood_logs = relationship("MoodLog", back_populates="visit", lazy="selectin")
    shoplifting_alerts = relationship("ShopliftingAlert", back_populates="visit", lazy="selectin")
