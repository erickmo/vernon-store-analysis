"""
Person tracker — re-identification visitor menggunakan face embedding.
Mengelola mapping antara deteksi per-frame dengan visitor persisten di DB.
"""

from __future__ import annotations

import uuid
from datetime import datetime, timezone

import numpy as np
import structlog

logger = structlog.get_logger(__name__)


class PersonTracker:
    """
    Mengelola tracking dan re-identification visitor antar frame.
    Menyimpan known embeddings di memory, sync ke DB secara periodik.
    """

    def __init__(self, similarity_threshold: float = 0.6) -> None:
        self.similarity_threshold = similarity_threshold
        # Map person_uid -> embedding vector
        self._known_embeddings: dict[str, np.ndarray] = {}
        # Map person_uid -> last_seen timestamp
        self._last_seen: dict[str, datetime] = {}

    def load_known_visitor(self, person_uid: str, embedding: bytes) -> None:
        """Load visitor yang sudah dikenal dari DB ke memory."""
        try:
            vector = np.frombytes(embedding, dtype=np.float64)
            self._known_embeddings[person_uid] = vector
        except Exception as e:
            logger.warning("failed to load embedding", person_uid=person_uid, error=str(e))

    def identify_or_register(self, face_embedding: np.ndarray | None) -> str:
        """
        Identifikasi person berdasarkan face embedding.
        Jika tidak dikenali, register sebagai visitor baru.

        Args:
            face_embedding: Face embedding vector atau None

        Returns:
            person_uid (existing atau baru)
        """
        if face_embedding is None:
            return f"unknown_{uuid.uuid4().hex[:12]}"

        # Cari match terbaik dari known embeddings
        best_match_uid: str | None = None
        best_distance = float("inf")

        for uid, known_embedding in self._known_embeddings.items():
            try:
                distance = float(np.linalg.norm(face_embedding - known_embedding))
                if distance < best_distance:
                    best_distance = distance
                    best_match_uid = uid
            except Exception:
                continue

        # Jika distance di bawah threshold, person dikenali
        if best_match_uid and best_distance < self.similarity_threshold:
            self._last_seen[best_match_uid] = datetime.now(timezone.utc)
            logger.debug(
                "person re-identified",
                person_uid=best_match_uid,
                distance=round(best_distance, 4),
            )
            return best_match_uid

        # Register visitor baru
        new_uid = f"VST_{uuid.uuid4().hex[:12]}"
        self._known_embeddings[new_uid] = face_embedding
        self._last_seen[new_uid] = datetime.now(timezone.utc)
        logger.info("new person registered", person_uid=new_uid)
        return new_uid

    def get_active_count(self, timeout_seconds: int = 300) -> int:
        """Mendapatkan jumlah orang yang aktif (terlihat dalam N detik terakhir)."""
        now = datetime.now(timezone.utc)
        count = 0
        for uid, last_seen in self._last_seen.items():
            if (now - last_seen).total_seconds() < timeout_seconds:
                count += 1
        return count

    def get_active_persons(self, timeout_seconds: int = 300) -> list[str]:
        """Mendapatkan list person_uid yang masih aktif."""
        now = datetime.now(timezone.utc)
        active = []
        for uid, last_seen in self._last_seen.items():
            if (now - last_seen).total_seconds() < timeout_seconds:
                active.append(uid)
        return active

    def serialize_embedding(self, embedding: np.ndarray) -> bytes:
        """Serialize numpy embedding ke bytes untuk disimpan di DB."""
        return embedding.tobytes()

    @property
    def known_count(self) -> int:
        """Jumlah total visitor yang dikenal."""
        return len(self._known_embeddings)
