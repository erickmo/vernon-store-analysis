"""Business logic untuk Camera."""

import structlog

from ..core.exceptions import NotFoundException
from ..models.db.camera import Camera
from ..models.request.camera_request import CameraCreateRequest, CameraUpdateRequest
from ..repositories.camera_repository import CameraRepository
from ..repositories.store_repository import StoreRepository

logger = structlog.get_logger(__name__)


class CameraService:
    """Service layer untuk operasi Camera."""

    def __init__(self, camera_repo: CameraRepository, store_repo: StoreRepository) -> None:
        self.camera_repo = camera_repo
        self.store_repo = store_repo

    async def list_cameras(self, store_id: int) -> list[Camera]:
        """Mendapatkan semua camera untuk store tertentu."""
        store = await self.store_repo.get_by_id(store_id)
        if not store:
            raise NotFoundException("Store")
        return await self.camera_repo.get_by_store(store_id)

    async def get_camera(self, camera_id: int) -> Camera:
        """Mendapatkan camera berdasarkan ID."""
        camera = await self.camera_repo.get_by_id(camera_id)
        if not camera:
            raise NotFoundException("Camera")
        return camera

    async def create_camera(self, store_id: int, data: CameraCreateRequest) -> Camera:
        """Mendaftarkan camera baru ke store."""
        store = await self.store_repo.get_by_id(store_id)
        if not store:
            raise NotFoundException("Store")
        camera = Camera(
            store_id=store_id,
            name=data.name,
            stream_url=data.stream_url,
            location_zone=data.location_zone,
            description=data.description,
        )
        camera = await self.camera_repo.create(camera)
        logger.info("camera registered", camera_id=camera.id, store_id=store_id)
        return camera

    async def update_camera(self, camera_id: int, data: CameraUpdateRequest) -> Camera:
        """Update camera."""
        camera = await self.get_camera(camera_id)
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(camera, field, value)
        camera = await self.camera_repo.update(camera)
        logger.info("camera updated", camera_id=camera.id)
        return camera

    async def delete_camera(self, camera_id: int) -> None:
        """Hapus camera."""
        camera = await self.get_camera(camera_id)
        await self.camera_repo.delete(camera)
        logger.info("camera deleted", camera_id=camera_id)
