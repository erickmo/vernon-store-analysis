"""Pydantic response models untuk Traffic."""

from datetime import datetime

from pydantic import BaseModel


class TrafficSnapshotResponse(BaseModel):
    """Response untuk single traffic snapshot."""

    id: int
    store_id: int
    timestamp: datetime
    visitor_count: int
    avg_dwell_seconds: float | None
    peak_count: int | None

    model_config = {"from_attributes": True}


class TrafficSummaryResponse(BaseModel):
    """Response untuk traffic summary."""

    success: bool = True
    store_id: int
    period_start: datetime
    period_end: datetime
    total_visitors: int
    avg_dwell_seconds: float | None
    peak_visitor_count: int | None
    snapshots: list[TrafficSnapshotResponse]


class RealtimeTrafficResponse(BaseModel):
    """Response untuk real-time visitor count."""

    success: bool = True
    store_id: int
    current_visitor_count: int
    timestamp: datetime
