"""Pydantic response models untuk Camera."""

from datetime import datetime

from pydantic import BaseModel


class CameraResponse(BaseModel):
    """Response untuk single camera."""

    id: int
    store_id: int
    name: str
    stream_url: str
    location_zone: str
    description: str | None
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class CameraListResponse(BaseModel):
    """Response untuk list cameras."""

    success: bool = True
    data: list[CameraResponse]
    total: int
