"""Pydantic request models untuk Auth."""

from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    """Request untuk register user baru."""

    email: EmailStr
    full_name: str = Field(..., min_length=1, max_length=255)
    password: str = Field(..., min_length=8, max_length=128)
    role: str = Field(default="viewer", pattern="^(admin|manager|viewer)$")


class LoginRequest(BaseModel):
    """Request untuk login."""

    email: EmailStr
    password: str = Field(..., min_length=1)


class RefreshTokenRequest(BaseModel):
    """Request untuk refresh access token."""

    refresh_token: str
