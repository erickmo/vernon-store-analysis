"""SQLAlchemy models — import semua model di sini agar Alembic mendeteksinya."""

from .camera import Camera
from .detection_log import DetectionLog
from .mood_log import MoodLog
from .shoplifting_alert import ShopliftingAlert
from .store import Store
from .traffic_snapshot import TrafficSnapshot
from .user import User
from .visit import Visit
from .visitor import Visitor

__all__ = [
    "Camera",
    "DetectionLog",
    "MoodLog",
    "ShopliftingAlert",
    "Store",
    "TrafficSnapshot",
    "User",
    "Visit",
    "Visitor",
]
