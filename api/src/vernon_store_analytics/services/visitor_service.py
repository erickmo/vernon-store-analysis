"""Business logic untuk Visitor dan Visit."""

import structlog

from ..core.exceptions import NotFoundException
from ..models.db.mood_log import MoodLog
from ..models.db.visit import Visit
from ..models.db.visitor import Visitor
from ..repositories.mood_log_repository import MoodLogRepository
from ..repositories.visit_repository import VisitRepository
from ..repositories.visitor_repository import VisitorRepository

logger = structlog.get_logger(__name__)


class VisitorService:
    """Service layer untuk operasi Visitor."""

    def __init__(
        self,
        visitor_repo: VisitorRepository,
        visit_repo: VisitRepository,
        mood_repo: MoodLogRepository,
    ) -> None:
        self.visitor_repo = visitor_repo
        self.visit_repo = visit_repo
        self.mood_repo = mood_repo

    async def list_visitors(
        self, store_id: int, limit: int = 50, offset: int = 0
    ) -> tuple[list[Visitor], int]:
        """Mendapatkan visitors untuk store tertentu dengan total count."""
        visitors = await self.visitor_repo.get_by_store(store_id, limit=limit, offset=offset)
        total = await self.visitor_repo.count_by_store(store_id)
        return visitors, total

    async def get_visitor(self, visitor_id: int) -> Visitor:
        """Mendapatkan visitor berdasarkan ID."""
        visitor = await self.visitor_repo.get_by_id(visitor_id)
        if not visitor:
            raise NotFoundException("Visitor")
        return visitor

    async def get_visitor_visits(self, visitor_id: int) -> list[Visit]:
        """Mendapatkan visit history untuk visitor."""
        visitor = await self.visitor_repo.get_by_id(visitor_id)
        if not visitor:
            raise NotFoundException("Visitor")
        return await self.visit_repo.get_by_visitor(visitor_id)

    async def get_mood_timeline(self, visitor_id: int, visit_id: int) -> list[MoodLog]:
        """Mendapatkan mood timeline untuk visit tertentu."""
        visit = await self.visit_repo.get_by_id(visit_id)
        if not visit or visit.visitor_id != visitor_id:
            raise NotFoundException("Visit")
        return await self.mood_repo.get_by_visit(visit_id)
