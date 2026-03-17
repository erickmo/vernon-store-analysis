"""Pydantic response models untuk ShopliftingAlert."""

from datetime import datetime

from pydantic import BaseModel


class AlertResponse(BaseModel):
    """Response untuk single shoplifting alert."""

    id: int
    visit_id: int
    camera_id: int
    confidence: float
    timestamp: datetime
    snapshot_path: str | None
    notified: bool
    resolved: bool
    resolved_at: datetime | None
    resolved_note: str | None
    created_at: datetime

    model_config = {"from_attributes": True}


class AlertListResponse(BaseModel):
    """Response untuk list alerts."""

    success: bool = True
    data: list[AlertResponse]
    total: int
