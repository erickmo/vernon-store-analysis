"""Pydantic request models untuk Store."""

from pydantic import BaseModel, Field


class StoreCreateRequest(BaseModel):
    """Request untuk membuat store baru."""

    name: str = Field(..., min_length=1, max_length=255)
    location: str = Field(..., min_length=1, max_length=500)
    timezone: str = Field(default="Asia/Jakarta", max_length=50)
    description: str | None = None


class StoreUpdateRequest(BaseModel):
    """Request untuk update store."""

    name: str | None = Field(None, min_length=1, max_length=255)
    location: str | None = Field(None, min_length=1, max_length=500)
    timezone: str | None = Field(None, max_length=50)
    description: str | None = None
    is_active: bool | None = None
