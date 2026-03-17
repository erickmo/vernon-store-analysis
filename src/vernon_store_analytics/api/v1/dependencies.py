"""
FastAPI dependencies yang digunakan di seluruh route.
"""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from ...core.exceptions import UnauthorizedException
from ...core.security import decode_token

security = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    """
    Dependency untuk mendapatkan user dari JWT token.

    Returns:
        Decoded token payload dengan user_id dan role

    Raises:
        HTTPException 401: Jika token tidak valid
    """
    try:
        payload = decode_token(credentials.credentials)
        if not payload.get("sub"):
            raise UnauthorizedException("Token tidak memiliki user ID")
        return payload
    except UnauthorizedException as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=e.message,
            headers={"WWW-Authenticate": "Bearer"},
        )


def require_role(*roles: str):
    """
    Dependency factory untuk memeriksa role user.

    Usage:
        @router.get("/admin", dependencies=[Depends(require_role("admin"))])

    Args:
        *roles: Role yang diizinkan mengakses endpoint
    """
    def check_role(current_user: dict = Depends(get_current_user)) -> dict:
        user_role = current_user.get("role")
        if user_role not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Akses ditolak",
            )
        return current_user

    return check_role
