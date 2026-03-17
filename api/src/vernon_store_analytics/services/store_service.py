"""Business logic untuk Store."""

import structlog

from ..core.exceptions import AlreadyExistsException, NotFoundException
from ..models.db.store import Store
from ..models.request.store_request import StoreCreateRequest, StoreUpdateRequest
from ..repositories.store_repository import StoreRepository

logger = structlog.get_logger(__name__)


class StoreService:
    """Service layer untuk operasi Store."""

    def __init__(self, repo: StoreRepository) -> None:
        self.repo = repo

    async def list_stores(self) -> list[Store]:
        """Mendapatkan semua store."""
        return await self.repo.get_all()

    async def get_store(self, store_id: int) -> Store:
        """Mendapatkan store berdasarkan ID."""
        store = await self.repo.get_by_id(store_id)
        if not store:
            raise NotFoundException("Store")
        return store

    async def create_store(self, data: StoreCreateRequest) -> Store:
        """Membuat store baru."""
        store = Store(
            name=data.name,
            location=data.location,
            timezone=data.timezone,
            description=data.description,
        )
        store = await self.repo.create(store)
        logger.info("store created", store_id=store.id, name=store.name)
        return store

    async def update_store(self, store_id: int, data: StoreUpdateRequest) -> Store:
        """Update store."""
        store = await self.get_store(store_id)
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(store, field, value)
        store = await self.repo.update(store)
        logger.info("store updated", store_id=store.id)
        return store

    async def delete_store(self, store_id: int) -> None:
        """Hapus store."""
        store = await self.get_store(store_id)
        await self.repo.delete(store)
        logger.info("store deleted", store_id=store_id)
