"""Repository untuk operasi database User."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.db.user import User


class UserRepository:
    """Data access layer untuk User entity."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_by_id(self, user_id: int) -> User | None:
        """Mendapatkan user berdasarkan ID."""
        result = await self.db.execute(select(User).where(User.id == user_id))
        return result.scalar_one_or_none()

    async def get_by_email(self, email: str) -> User | None:
        """Mendapatkan user berdasarkan email."""
        result = await self.db.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()

    async def create(self, user: User) -> User:
        """Membuat user baru."""
        self.db.add(user)
        await self.db.flush()
        await self.db.refresh(user)
        return user
