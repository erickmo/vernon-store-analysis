"""API routes untuk Camera management."""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...models.request.camera_request import CameraCreateRequest, CameraUpdateRequest
from ...models.response.camera_response import CameraListResponse, CameraResponse
from ...models.response.common import SuccessResponse
from ...repositories.camera_repository import CameraRepository
from ...repositories.store_repository import StoreRepository
from ...services.camera_service import CameraService
from .dependencies import get_current_user

router = APIRouter(prefix="/stores/{store_id}/cameras", tags=["cameras"])


def _get_service(db: AsyncSession = Depends(get_db)) -> CameraService:
    return CameraService(CameraRepository(db), StoreRepository(db))


@router.get("", response_model=CameraListResponse)
async def list_cameras(
    store_id: int,
    service: CameraService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Mendapatkan daftar camera untuk store tertentu."""
    cameras = await service.list_cameras(store_id)
    return CameraListResponse(
        data=[CameraResponse.model_validate(c) for c in cameras],
        total=len(cameras),
    )


@router.post("", response_model=CameraResponse, status_code=201)
async def create_camera(
    store_id: int,
    data: CameraCreateRequest,
    service: CameraService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Mendaftarkan camera baru ke store."""
    camera = await service.create_camera(store_id, data)
    return CameraResponse.model_validate(camera)


@router.put("/{camera_id}", response_model=CameraResponse)
async def update_camera(
    store_id: int,
    camera_id: int,
    data: CameraUpdateRequest,
    service: CameraService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Update camera."""
    camera = await service.update_camera(camera_id, data)
    return CameraResponse.model_validate(camera)


@router.delete("/{camera_id}", response_model=SuccessResponse)
async def delete_camera(
    store_id: int,
    camera_id: int,
    service: CameraService = Depends(_get_service),
    _: dict = Depends(get_current_user),
):
    """Hapus camera."""
    await service.delete_camera(camera_id)
    return SuccessResponse(message="Camera berhasil dihapus")
