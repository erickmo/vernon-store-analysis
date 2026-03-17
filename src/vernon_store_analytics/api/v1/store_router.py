"""API routes untuk Store management."""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...models.request.store_request import StoreCreateRequest, StoreUpdateRequest
from ...models.response.common import SuccessResponse
from ...models.response.store_response import StoreListResponse, StoreResponse
from ...repositories.store_repository import StoreRepository
from ...services.store_service import StoreService
from .dependencies import get_current_user

router = APIRouter(prefix="/stores", tags=["stores"])


def _get_service(db: AsyncSession = Depends(get_db)) -> StoreService:
    return StoreService(StoreRepository(db))


@router.get("", response_model=StoreListResponse)
async def list_stores(
    service: StoreService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Mendapatkan daftar semua store."""
    stores = await service.list_stores()
    return StoreListResponse(
        data=[StoreResponse.model_validate(s) for s in stores],
        total=len(stores),
    )


@router.get("/{store_id}", response_model=StoreResponse)
async def get_store(
    store_id: int,
    service: StoreService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Mendapatkan detail store berdasarkan ID."""
    store = await service.get_store(store_id)
    return StoreResponse.model_validate(store)


@router.post("", response_model=StoreResponse, status_code=201)
async def create_store(
    data: StoreCreateRequest,
    service: StoreService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Membuat store baru."""
    store = await service.create_store(data)
    return StoreResponse.model_validate(store)


@router.put("/{store_id}", response_model=StoreResponse)
async def update_store(
    store_id: int,
    data: StoreUpdateRequest,
    service: StoreService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Update store."""
    store = await service.update_store(store_id, data)
    return StoreResponse.model_validate(store)


@router.delete("/{store_id}", response_model=SuccessResponse)
async def delete_store(
    store_id: int,
    service: StoreService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Hapus store."""
    await service.delete_store(store_id)
    return SuccessResponse(message="Store berhasil dihapus")
