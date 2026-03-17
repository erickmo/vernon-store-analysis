"""Pydantic response models untuk Visitor."""

from datetime import datetime

from pydantic import BaseModel


class VisitorResponse(BaseModel):
    """Response untuk single visitor."""

    id: int
    store_id: int
    person_uid: str
    label: str | None
    first_seen_at: datetime
    last_seen_at: datetime
    total_visits: int
    created_at: datetime

    model_config = {"from_attributes": True}


class VisitorListResponse(BaseModel):
    """Response untuk list visitors."""

    success: bool = True
    data: list[VisitorResponse]
    total: int


class MoodLogResponse(BaseModel):
    """Response untuk single mood log entry."""

    id: int
    visit_id: int
    timestamp: datetime
    mood: str
    confidence: float

    model_config = {"from_attributes": True}


class VisitResponse(BaseModel):
    """Response untuk single visit."""

    id: int
    visitor_id: int
    camera_id: int
    entry_at: datetime
    exit_at: datetime | None
    dwell_seconds: int | None

    model_config = {"from_attributes": True}


class VisitorDetailResponse(BaseModel):
    """Response untuk visitor detail dengan visit history."""

    success: bool = True
    data: VisitorResponse
    visits: list[VisitResponse]


class MoodTimelineResponse(BaseModel):
    """Response untuk mood timeline sebuah visit."""

    success: bool = True
    data: list[MoodLogResponse]
