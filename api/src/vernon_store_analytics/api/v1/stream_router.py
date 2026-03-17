"""API routes untuk CCTV Stream management dan WebSocket real-time."""

import json

from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...models.response.common import SuccessResponse
from ...repositories.camera_repository import CameraRepository
from ...services.stream.stream_manager import StreamManager
from .dependencies import get_current_user

router = APIRouter(prefix="/stream", tags=["stream"])


def _get_stream_manager() -> StreamManager:
    return StreamManager.get_instance()


@router.get("/status")
async def get_stream_status(
    manager: StreamManager = Depends(_get_stream_manager),
    _: dict = Depends(get_current_user),
):
    """Status semua CCTV stream yang terdaftar."""
    stats = manager.get_all_stats()
    return {
        "success": True,
        "active_cameras": manager.active_camera_count,
        "registered_cameras": manager.registered_camera_count,
        "cameras": [
            {
                "camera_id": s.camera_id,
                "store_id": s.store_id,
                "zone": s.zone,
                "is_running": s.is_running,
                "persons_in_frame": s.persons_in_frame,
                "total_detections": s.total_detections,
                "last_frame_at": s.last_frame_at.isoformat() if s.last_frame_at else None,
            }
            for s in stats
        ],
    }


@router.post("/cameras/{camera_id}/start", response_model=SuccessResponse)
async def start_camera_stream(
    camera_id: int,
    db: AsyncSession = Depends(get_db),
    manager: StreamManager = Depends(_get_stream_manager),
    _: dict = Depends(get_current_user),
):
    """Mulai streaming dan analisis dari satu camera."""
    camera_repo = CameraRepository(db)
    camera = await camera_repo.get_by_id(camera_id)
    if not camera:
        return SuccessResponse(success=False, message="Camera tidak ditemukan")

    await manager.register_camera(camera)
    started = await manager.start_camera(camera_id)

    if started:
        return SuccessResponse(message=f"Stream camera {camera_id} dimulai")
    return SuccessResponse(success=False, message=f"Gagal memulai stream camera {camera_id}")


@router.post("/cameras/{camera_id}/stop", response_model=SuccessResponse)
async def stop_camera_stream(
    camera_id: int,
    manager: StreamManager = Depends(_get_stream_manager),
    _: dict = Depends(get_current_user),
):
    """Stop streaming dari satu camera."""
    await manager.stop_camera(camera_id)
    return SuccessResponse(message=f"Stream camera {camera_id} dihentikan")


@router.post("/start-all", response_model=SuccessResponse)
async def start_all_streams(
    db: AsyncSession = Depends(get_db),
    manager: StreamManager = Depends(_get_stream_manager),
    _: dict = Depends(get_current_user),
):
    """Register dan start semua active cameras."""
    camera_repo = CameraRepository(db)
    # Get all active cameras from all stores
    from sqlalchemy import select
    from ...models.db.camera import Camera
    result = await db.execute(select(Camera).where(Camera.is_active.is_(True)))
    cameras = result.scalars().all()

    for camera in cameras:
        await manager.register_camera(camera)

    await manager.start_all()
    return SuccessResponse(message=f"{len(cameras)} camera streams dimulai")


@router.post("/stop-all", response_model=SuccessResponse)
async def stop_all_streams(
    manager: StreamManager = Depends(_get_stream_manager),
    _: dict = Depends(get_current_user),
):
    """Stop semua camera streams."""
    await manager.stop_all()
    return SuccessResponse(message="Semua stream dihentikan")


@router.get("/shoplifting/scores")
async def get_shoplifting_scores(
    manager: StreamManager = Depends(_get_stream_manager),
    _: dict = Depends(get_current_user),
):
    """
    Mendapatkan shoplifting risk score semua visitor yang sedang di-track.
    Sorted by confidence (tertinggi dulu).
    """
    detector = manager.shoplifting_detector
    scores = detector.get_all_scores()
    return {
        "success": True,
        "threshold": detector.threshold,
        "active_profiles": detector.active_profiles_count,
        "scores": [s.to_dict() for s in scores],
    }


@router.get("/shoplifting/profile/{person_uid}")
async def get_shoplifting_profile(
    person_uid: str,
    manager: StreamManager = Depends(_get_stream_manager),
    _: dict = Depends(get_current_user),
):
    """Mendapatkan detail behavior profile satu visitor."""
    detector = manager.shoplifting_detector
    profile = detector.get_profile(person_uid)
    if not profile:
        return {"success": False, "error": "Profile tidak ditemukan"}

    score = detector.evaluate(person_uid)
    return {
        "success": True,
        "profile": {
            "person_uid": profile.person_uid,
            "visit_id": profile.visit_id,
            "first_seen": profile.first_seen.isoformat(),
            "last_seen": profile.last_seen.isoformat(),
            "total_dwell_seconds": round(profile.total_dwell_seconds),
            "zones_visited": profile.zones_visited,
            "zone_dwell": {k: round(v, 1) for k, v in profile.zone_dwell.items()},
            "zone_changes": profile.zone_changes,
            "detection_count": profile.detection_count,
            "visited_cashier": profile.visited_cashier,
            "visited_exit": profile.visited_exit,
            "dominant_mood": profile.dominant_mood,
            "nervous_ratio": round(profile.nervous_ratio, 3),
            "moods": [{"mood": m, "confidence": round(c, 3)} for m, c in profile.moods],
        },
        "score": score.to_dict() if score else None,
    }


@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """
    WebSocket endpoint untuk real-time detection updates.
    Client akan menerima JSON message setiap kali ada deteksi baru:
    {
        "type": "detection_update",
        "camera_id": 1,
        "timestamp": "...",
        "persons_count": 3,
        "detections": [
            {"person_uid": "...", "gender": "...", "age_estimate": 25, "mood": "happy", ...}
        ]
    }
    """
    await websocket.accept()
    manager = StreamManager.get_instance()
    manager.add_ws_client(websocket)

    try:
        # Send initial status
        stats = manager.get_all_stats()
        await websocket.send_json({
            "type": "connected",
            "active_cameras": manager.active_camera_count,
            "cameras": [
                {
                    "camera_id": s.camera_id,
                    "zone": s.zone,
                    "is_running": s.is_running,
                }
                for s in stats
            ],
        })

        # Keep connection alive, listen for client messages
        while True:
            data = await websocket.receive_text()
            # Client bisa kirim ping atau request status
            try:
                msg = json.loads(data)
                if msg.get("type") == "ping":
                    await websocket.send_json({"type": "pong"})
                elif msg.get("type") == "status":
                    stats = manager.get_all_stats()
                    await websocket.send_json({
                        "type": "status",
                        "active_cameras": manager.active_camera_count,
                    })
            except json.JSONDecodeError:
                pass

    except WebSocketDisconnect:
        manager.remove_ws_client(websocket)
    except Exception:
        manager.remove_ws_client(websocket)
