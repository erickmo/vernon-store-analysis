"""Common response models."""

from pydantic import BaseModel


class SuccessResponse(BaseModel):
    """Generic success response."""

    success: bool = True
    message: str


class ErrorResponse(BaseModel):
    """Generic error response."""

    success: bool = False
    error: str
