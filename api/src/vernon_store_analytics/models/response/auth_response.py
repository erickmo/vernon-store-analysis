"""Pydantic response models untuk Auth."""

from datetime import datetime

from pydantic import BaseModel


class TokenResponse(BaseModel):
    """Response setelah login/refresh berhasil."""

    success: bool = True
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class UserResponse(BaseModel):
    """Response untuk user profile."""

    id: int
    email: str
    full_name: str
    role: str
    is_active: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class RegisterResponse(BaseModel):
    """Response setelah register berhasil."""

    success: bool = True
    message: str = "User berhasil didaftarkan"
    user: UserResponse
