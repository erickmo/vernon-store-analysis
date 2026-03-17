"""SQLAlchemy model untuk MoodLog."""

from datetime import datetime, timezone

from sqlalchemy import DateTime, Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ...core.database import Base


class MoodLog(Base):
    """
    Log mood visitor pada waktu tertentu selama kunjungan.

    Zone types:
    - entry: saat masuk store
    - exit: saat keluar store
    - cashier: saat di area kasir
    - floor: saat di area umum store
    """

    __tablename__ = "mood_logs"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    visit_id: Mapped[int] = mapped_column(ForeignKey("visits.id"), nullable=False)
    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    zone: Mapped[str] = mapped_column(String(20), nullable=False, default="floor")
    mood: Mapped[str] = mapped_column(String(50), nullable=False)
    confidence: Mapped[float] = mapped_column(Float, nullable=False)

    # Relationships
    visit = relationship("Visit", back_populates="mood_logs")
