"""Pydantic response models untuk Store."""

from datetime import datetime

from pydantic import BaseModel


class StoreResponse(BaseModel):
    """Response untuk single store."""

    id: int
    name: str
    location: str
    timezone: str
    description: str | None
    is_active: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class StoreListResponse(BaseModel):
    """Response untuk list stores."""

    success: bool = True
    data: list[StoreResponse]
    total: int
