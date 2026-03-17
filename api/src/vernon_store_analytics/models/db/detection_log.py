"""SQLAlchemy model untuk DetectionLog — per-frame detection data dari CCTV."""

from datetime import datetime, timezone

from sqlalchemy import DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ...core.database import Base


class DetectionLog(Base):
    """
    Log setiap kali seseorang terdeteksi dalam frame CCTV.
    Menyimpan raw detection data untuk analytics.
    """

    __tablename__ = "detection_logs"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    visit_id: Mapped[int] = mapped_column(ForeignKey("visits.id"), nullable=False)
    camera_id: Mapped[int] = mapped_column(ForeignKey("cameras.id"), nullable=False)
    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    zone: Mapped[str] = mapped_column(String(20), nullable=False, default="floor")

    # Detection data
    gender: Mapped[str | None] = mapped_column(String(20), nullable=True)
    age_estimate: Mapped[int | None] = mapped_column(Integer, nullable=True)
    mood: Mapped[str | None] = mapped_column(String(50), nullable=True)
    mood_confidence: Mapped[float | None] = mapped_column(Float, nullable=True)

    # Bounding box (untuk tracking)
    bbox_x: Mapped[int | None] = mapped_column(Integer, nullable=True)
    bbox_y: Mapped[int | None] = mapped_column(Integer, nullable=True)
    bbox_w: Mapped[int | None] = mapped_column(Integer, nullable=True)
    bbox_h: Mapped[int | None] = mapped_column(Integer, nullable=True)

    # Relationships
    visit = relationship("Visit")
    camera = relationship("Camera")
