"""
Fungsi untuk JWT token generation dan verification.
"""

from datetime import datetime, timedelta, timezone
from typing import Any

from jose import JWTError, jwt
from passlib.context import CryptContext

from .config import get_settings
from .exceptions import UnauthorizedException

settings = get_settings()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    """Menghasilkan hash bcrypt dari password."""
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Memverifikasi password dengan hash-nya."""
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict[str, Any]) -> str:
    """
    Membuat JWT access token.

    Args:
        data: Payload yang akan di-encode (biasanya {"sub": user_id, "role": role})

    Returns:
        JWT token string
    """
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.access_token_expire_minutes
    )
    to_encode["exp"] = expire
    to_encode["type"] = "access"
    return jwt.encode(to_encode, settings.secret_key, algorithm=settings.jwt_algorithm)


def create_refresh_token(data: dict[str, Any]) -> str:
    """
    Membuat JWT refresh token (lifetime lebih panjang).

    Args:
        data: Payload minimal {"sub": user_id}

    Returns:
        JWT refresh token string
    """
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(
        days=settings.refresh_token_expire_days
    )
    to_encode["exp"] = expire
    to_encode["type"] = "refresh"
    return jwt.encode(to_encode, settings.secret_key, algorithm=settings.jwt_algorithm)


def decode_token(token: str) -> dict[str, Any]:
    """
    Mendekode dan memverifikasi JWT token.

    Args:
        token: JWT token string

    Returns:
        Decoded payload

    Raises:
        UnauthorizedException: Jika token tidak valid atau expired
    """
    try:
        payload = jwt.decode(
            token,
            settings.secret_key,
            algorithms=[settings.jwt_algorithm],
        )
        return payload
    except JWTError as e:
        raise UnauthorizedException(f"Token tidak valid: {e}") from e
