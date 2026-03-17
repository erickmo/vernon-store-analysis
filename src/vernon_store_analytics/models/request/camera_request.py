"""Pydantic request models untuk Camera."""

from pydantic import BaseModel, Field


class CameraCreateRequest(BaseModel):
    """Request untuk mendaftarkan camera baru."""

    name: str = Field(..., min_length=1, max_length=255)
    stream_url: str = Field(..., min_length=1, max_length=1000)
    location_zone: str = Field(..., min_length=1, max_length=255)
    description: str | None = None


class CameraUpdateRequest(BaseModel):
    """Request untuk update camera."""

    name: str | None = Field(None, min_length=1, max_length=255)
    stream_url: str | None = Field(None, min_length=1, max_length=1000)
    location_zone: str | None = Field(None, min_length=1, max_length=255)
    description: str | None = None
    is_active: bool | None = None
