"""Business logic untuk Authentication."""

import structlog

from ..core.config import get_settings
from ..core.exceptions import (
    AlreadyExistsException,
    NotFoundException,
    UnauthorizedException,
    ValidationException,
)
from ..core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from ..models.db.user import User
from ..models.request.auth_request import LoginRequest, RefreshTokenRequest, RegisterRequest
from ..repositories.user_repository import UserRepository

logger = structlog.get_logger(__name__)
settings = get_settings()


class AuthService:
    """Service layer untuk authentication."""

    def __init__(self, user_repo: UserRepository) -> None:
        self.user_repo = user_repo

    async def register(self, data: RegisterRequest) -> User:
        """Register user baru."""
        existing = await self.user_repo.get_by_email(data.email)
        if existing:
            raise AlreadyExistsException("User dengan email ini")

        user = User(
            email=data.email,
            full_name=data.full_name,
            hashed_password=hash_password(data.password),
            role=data.role,
        )
        user = await self.user_repo.create(user)
        logger.info("user registered", user_id=user.id, email=user.email, role=user.role)
        return user

    async def login(self, data: LoginRequest) -> dict:
        """
        Login user — return access + refresh token.

        Raises:
            UnauthorizedException: Jika email/password salah atau user inactive
        """
        user = await self.user_repo.get_by_email(data.email)
        if not user:
            raise UnauthorizedException("Email atau password salah")

        if not verify_password(data.password, user.hashed_password):
            raise UnauthorizedException("Email atau password salah")

        if not user.is_active:
            raise UnauthorizedException("Akun tidak aktif")

        token_payload = {
            "sub": str(user.id),
            "email": user.email,
            "role": user.role,
            "name": user.full_name,
        }

        access_token = create_access_token(token_payload)
        refresh_token = create_refresh_token({"sub": str(user.id)})

        logger.info("user logged in", user_id=user.id, email=user.email)

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "expires_in": settings.access_token_expire_minutes * 60,
        }

    async def refresh_token(self, data: RefreshTokenRequest) -> dict:
        """
        Refresh access token menggunakan refresh token.

        Raises:
            UnauthorizedException: Jika refresh token tidak valid
        """
        payload = decode_token(data.refresh_token)

        if payload.get("type") != "refresh":
            raise UnauthorizedException("Token bukan refresh token")

        user_id = payload.get("sub")
        if not user_id:
            raise UnauthorizedException("Token tidak valid")

        user = await self.user_repo.get_by_id(int(user_id))
        if not user or not user.is_active:
            raise UnauthorizedException("User tidak ditemukan atau tidak aktif")

        token_payload = {
            "sub": str(user.id),
            "email": user.email,
            "role": user.role,
            "name": user.full_name,
        }

        access_token = create_access_token(token_payload)
        refresh_token = create_refresh_token({"sub": str(user.id)})

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "expires_in": settings.access_token_expire_minutes * 60,
        }

    async def get_current_user(self, user_id: int) -> User:
        """Mendapatkan user dari ID (dari JWT payload)."""
        user = await self.user_repo.get_by_id(user_id)
        if not user:
            raise NotFoundException("User")
        if not user.is_active:
            raise UnauthorizedException("Akun tidak aktif")
        return user
