"""
Frame analyzer — menggunakan DeepFace untuk analisis wajah.
Mendeteksi: person, gender, age, emotion dari frame CCTV.
"""

from __future__ import annotations

import uuid
from dataclasses import dataclass, field
from typing import Any

import numpy as np
import structlog

logger = structlog.get_logger(__name__)


@dataclass
class PersonDetection:
    """Hasil deteksi satu orang dalam frame."""

    person_uid: str
    gender: str | None = None
    age_estimate: int | None = None
    age_group: str | None = None
    dominant_emotion: str | None = None
    emotion_confidence: float = 0.0
    emotions: dict[str, float] = field(default_factory=dict)
    bbox: tuple[int, int, int, int] | None = None  # x, y, w, h
    face_embedding: np.ndarray | None = None


def _classify_age_group(age: int) -> str:
    """Klasifikasi usia ke age group."""
    if age < 13:
        return "child"
    elif age < 18:
        return "teenager"
    elif age < 26:
        return "young_adult"
    elif age < 40:
        return "adult"
    elif age < 60:
        return "middle_aged"
    return "senior"


class FrameAnalyzer:
    """
    Menganalisis frame CCTV untuk mendeteksi orang dan atributnya.
    Menggunakan DeepFace untuk face analysis (age, gender, emotion).
    """

    def __init__(self) -> None:
        self._initialized = False
        self._detector_backend = "opencv"

    def _ensure_initialized(self) -> None:
        """Lazy initialization — load model saat pertama kali dipanggil."""
        if self._initialized:
            return
        try:
            from deepface import DeepFace  # noqa: F401
            logger.info("deepface initialized", backend=self._detector_backend)
            self._initialized = True
        except ImportError:
            logger.warning("deepface not installed, using mock analyzer")
            self._initialized = True

    def analyze_frame(self, frame: np.ndarray) -> list[PersonDetection]:
        """
        Menganalisis satu frame dan mengembalikan list PersonDetection.

        Args:
            frame: numpy array BGR image dari OpenCV

        Returns:
            List of PersonDetection untuk setiap orang yang terdeteksi
        """
        self._ensure_initialized()

        try:
            from deepface import DeepFace
        except ImportError:
            return []

        detections: list[PersonDetection] = []

        try:
            results = DeepFace.analyze(
                img_path=frame,
                actions=["age", "gender", "emotion"],
                detector_backend=self._detector_backend,
                enforce_detection=False,
                silent=True,
            )

            if isinstance(results, dict):
                results = [results]

            for result in results:
                region = result.get("region", {})
                if not region or (region.get("w", 0) < 30 and region.get("h", 0) < 30):
                    continue

                age = int(result.get("age", 0))
                gender_data = result.get("gender", {})
                if isinstance(gender_data, dict):
                    gender = max(gender_data, key=gender_data.get) if gender_data else None
                else:
                    gender = str(gender_data) if gender_data else None

                emotions = result.get("emotion", {})
                dominant_emotion = result.get("dominant_emotion", "neutral")
                emotion_conf = emotions.get(dominant_emotion, 0.0) / 100.0 if emotions else 0.0

                # Generate temporary UID (akan di-resolve oleh re-identification)
                person_uid = f"temp_{uuid.uuid4().hex[:12]}"

                detection = PersonDetection(
                    person_uid=person_uid,
                    gender=gender.lower() if gender else None,
                    age_estimate=age if age > 0 else None,
                    age_group=_classify_age_group(age) if age > 0 else None,
                    dominant_emotion=dominant_emotion,
                    emotion_confidence=round(emotion_conf, 3),
                    emotions={k: round(v / 100.0, 3) for k, v in emotions.items()},
                    bbox=(
                        region.get("x", 0),
                        region.get("y", 0),
                        region.get("w", 0),
                        region.get("h", 0),
                    ),
                )
                detections.append(detection)

        except Exception as e:
            logger.error("frame analysis failed", error=str(e))

        return detections

    def get_face_embedding(self, frame: np.ndarray) -> np.ndarray | None:
        """
        Mendapatkan face embedding untuk re-identification.

        Args:
            frame: Cropped face image

        Returns:
            Face embedding vector atau None
        """
        self._ensure_initialized()

        try:
            from deepface import DeepFace

            embeddings = DeepFace.represent(
                img_path=frame,
                model_name="Facenet512",
                detector_backend=self._detector_backend,
                enforce_detection=False,
            )
            if embeddings:
                return np.array(embeddings[0]["embedding"])
        except Exception as e:
            logger.error("face embedding failed", error=str(e))

        return None

    def compare_faces(
        self, embedding1: np.ndarray, embedding2: np.ndarray, threshold: float = 0.6
    ) -> bool:
        """
        Membandingkan dua face embedding.

        Returns:
            True jika kedua embedding milik orang yang sama
        """
        distance = np.linalg.norm(embedding1 - embedding2)
        return float(distance) < threshold
