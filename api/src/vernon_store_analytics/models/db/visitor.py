"""SQLAlchemy model untuk Visitor."""

from datetime import datetime, timezone

from sqlalchemy import DateTime, Float, ForeignKey, Integer, LargeBinary, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from ...core.database import Base


class Visitor(Base):
    """Unique person yang terdeteksi oleh sistem."""

    __tablename__ = "visitors"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    store_id: Mapped[int] = mapped_column(ForeignKey("stores.id"), nullable=False)
    person_uid: Mapped[str] = mapped_column(
        String(100), unique=True, nullable=False, index=True
    )
    person_embedding: Mapped[bytes | None] = mapped_column(LargeBinary, nullable=True)
    label: Mapped[str | None] = mapped_column(String(255), nullable=True)

    # Demographics
    gender: Mapped[str | None] = mapped_column(String(20), nullable=True)
    age_estimate: Mapped[int | None] = mapped_column(Integer, nullable=True)
    age_group: Mapped[str | None] = mapped_column(String(20), nullable=True)

    first_seen_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    last_seen_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )
    total_visits: Mapped[int] = mapped_column(default=0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(timezone.utc)
    )

    # Relationships
    store = relationship("Store", back_populates="visitors")
    visits = relationship("Visit", back_populates="visitor", lazy="selectin")
