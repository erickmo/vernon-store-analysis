"""API routes untuk Authentication — register, login, refresh, profile."""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...models.request.auth_request import LoginRequest, RefreshTokenRequest, RegisterRequest
from ...models.response.auth_response import RegisterResponse, TokenResponse, UserResponse
from ...repositories.user_repository import UserRepository
from ...services.auth_service import AuthService
from .dependencies import get_current_user

router = APIRouter(prefix="/auth", tags=["auth"])


def _get_service(db: AsyncSession = Depends(get_db)) -> AuthService:
    return AuthService(UserRepository(db))


@router.post("/register", response_model=RegisterResponse, status_code=201)
async def register(
    data: RegisterRequest,
    service: AuthService = Depends(_get_service),
):
    """
    Register user baru.
    Roles: admin, manager, viewer (default: viewer).
    """
    user = await service.register(data)
    return RegisterResponse(user=UserResponse.model_validate(user))


@router.post("/login", response_model=TokenResponse)
async def login(
    data: LoginRequest,
    service: AuthService = Depends(_get_service),
):
    """
    Login dan dapatkan access token + refresh token.
    Access token berlaku 15 menit, refresh token 7 hari.
    """
    result = await service.login(data)
    return TokenResponse(**result)


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    data: RefreshTokenRequest,
    service: AuthService = Depends(_get_service),
):
    """Refresh access token menggunakan refresh token."""
    result = await service.refresh_token(data)
    return TokenResponse(**result)


@router.get("/me", response_model=UserResponse)
async def get_me(
    current_user: dict = Depends(get_current_user),
    service: AuthService = Depends(_get_service),
):
    """Mendapatkan profil user yang sedang login."""
    user_id = int(current_user["sub"])
    user = await service.get_current_user(user_id)
    return UserResponse.model_validate(user)
