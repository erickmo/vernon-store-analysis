"""
Repository untuk aggregasi analytics — query statistik pengunjung, gender, usia, mood, dwell time.
"""

from datetime import datetime

from sqlalchemy import Float, String, cast, case, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.db.detection_log import DetectionLog
from ..models.db.mood_log import MoodLog
from ..models.db.visit import Visit
from ..models.db.visitor import Visitor


class AnalyticsRepository:
    """Data access layer untuk analytics aggregation queries."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def get_visitor_count(self, store_id: int, start: datetime, end: datetime) -> int:
        """Total unique visitor dalam periode."""
        result = await self.db.execute(
            select(func.count(func.distinct(Visitor.id)))
            .select_from(Visitor)
            .join(Visit, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start,
                Visit.entry_at <= end,
            )
        )
        return result.scalar_one()

    async def get_gender_stats(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        """Statistik gender pengunjung."""
        result = await self.db.execute(
            select(
                Visitor.gender,
                func.count(func.distinct(Visitor.id)).label("count"),
            )
            .join(Visit, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start,
                Visit.entry_at <= end,
            )
            .group_by(Visitor.gender)
        )
        rows = result.all()
        total = sum(r.count for r in rows)
        return [
            {
                "gender": r.gender or "unknown",
                "count": r.count,
                "percentage": round(r.count / total * 100, 1) if total > 0 else 0,
            }
            for r in rows
        ]

    async def get_age_stats(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        """Statistik age group pengunjung."""
        result = await self.db.execute(
            select(
                Visitor.age_group,
                func.count(func.distinct(Visitor.id)).label("count"),
                func.avg(Visitor.age_estimate).label("avg_age"),
            )
            .join(Visit, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start,
                Visit.entry_at <= end,
            )
            .group_by(Visitor.age_group)
        )
        rows = result.all()
        total = sum(r.count for r in rows)
        return [
            {
                "age_group": r.age_group or "unknown",
                "count": r.count,
                "percentage": round(r.count / total * 100, 1) if total > 0 else 0,
                "avg_age": round(float(r.avg_age), 1) if r.avg_age else None,
            }
            for r in rows
        ]

    async def get_mood_stats_by_zone(
        self, store_id: int, start: datetime, end: datetime, zone: str
    ) -> list[dict]:
        """Statistik mood di zone tertentu (entry/exit/cashier/floor)."""
        result = await self.db.execute(
            select(
                MoodLog.mood,
                func.count().label("count"),
                func.avg(MoodLog.confidence).label("avg_confidence"),
            )
            .join(Visit, MoodLog.visit_id == Visit.id)
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                MoodLog.zone == zone,
                MoodLog.timestamp >= start,
                MoodLog.timestamp <= end,
            )
            .group_by(MoodLog.mood)
            .order_by(func.count().desc())
        )
        rows = result.all()
        total = sum(r.count for r in rows)
        return [
            {
                "mood": r.mood,
                "count": r.count,
                "percentage": round(r.count / total * 100, 1) if total > 0 else 0,
                "avg_confidence": round(float(r.avg_confidence), 3) if r.avg_confidence else 0,
            }
            for r in rows
        ]

    async def get_all_zone_mood_stats(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict[str, list[dict]]:
        """Statistik mood untuk semua zone sekaligus."""
        zones = ["entry", "exit", "cashier", "floor"]
        result = {}
        for zone in zones:
            result[zone] = await self.get_mood_stats_by_zone(store_id, start, end, zone)
        return result

    async def get_dwell_time_stats(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """Statistik dwell time (lama di dalam store)."""
        result = await self.db.execute(
            select(
                func.count(Visit.id).label("total_visits"),
                func.avg(Visit.dwell_seconds).label("avg_dwell"),
                func.min(Visit.dwell_seconds).label("min_dwell"),
                func.max(Visit.dwell_seconds).label("max_dwell"),
            )
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start,
                Visit.entry_at <= end,
                Visit.dwell_seconds.isnot(None),
            )
        )
        row = result.one()
        return {
            "total_visits": row.total_visits or 0,
            "avg_dwell_seconds": round(float(row.avg_dwell), 1) if row.avg_dwell else 0,
            "min_dwell_seconds": row.min_dwell or 0,
            "max_dwell_seconds": row.max_dwell or 0,
            "avg_dwell_minutes": round(float(row.avg_dwell) / 60, 1) if row.avg_dwell else 0,
        }

    async def get_dwell_time_distribution(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        """Distribusi dwell time dalam bucket."""
        result = await self.db.execute(
            select(
                case(
                    (Visit.dwell_seconds < 60, "< 1 min"),
                    (Visit.dwell_seconds < 300, "1-5 min"),
                    (Visit.dwell_seconds < 900, "5-15 min"),
                    (Visit.dwell_seconds < 1800, "15-30 min"),
                    (Visit.dwell_seconds < 3600, "30-60 min"),
                    else_="> 60 min",
                ).label("bucket"),
                func.count().label("count"),
            )
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start,
                Visit.entry_at <= end,
                Visit.dwell_seconds.isnot(None),
            )
            .group_by("bucket")
        )
        rows = result.all()
        total = sum(r.count for r in rows)
        return [
            {
                "bucket": r.bucket,
                "count": r.count,
                "percentage": round(r.count / total * 100, 1) if total > 0 else 0,
            }
            for r in rows
        ]

    async def get_hourly_traffic(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        """Traffic per jam."""
        result = await self.db.execute(
            select(
                func.date_trunc("hour", Visit.entry_at).label("hour"),
                func.count(func.distinct(Visit.visitor_id)).label("visitor_count"),
            )
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start,
                Visit.entry_at <= end,
            )
            .group_by("hour")
            .order_by("hour")
        )
        return [
            {
                "hour": str(r.hour),
                "visitor_count": r.visitor_count,
            }
            for r in result.all()
        ]

    async def get_visitor_details_list(
        self, store_id: int, start: datetime, end: datetime, limit: int = 50, offset: int = 0
    ) -> list[dict]:
        """List detail visitor dengan demographics dan mood entry/exit."""
        # Get visitors with their visits
        visitors_result = await self.db.execute(
            select(
                Visitor.id,
                Visitor.person_uid,
                Visitor.gender,
                Visitor.age_estimate,
                Visitor.age_group,
                Visit.entry_at,
                Visit.exit_at,
                Visit.dwell_seconds,
                Visit.id.label("visit_id"),
            )
            .join(Visit, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start,
                Visit.entry_at <= end,
            )
            .order_by(Visit.entry_at.desc())
            .limit(limit)
            .offset(offset)
        )
        rows = visitors_result.all()

        details = []
        for row in rows:
            # Get entry mood
            entry_mood = await self.db.execute(
                select(MoodLog.mood, MoodLog.confidence)
                .where(MoodLog.visit_id == row.visit_id, MoodLog.zone == "entry")
                .order_by(MoodLog.timestamp.asc())
                .limit(1)
            )
            entry_mood_row = entry_mood.first()

            # Get exit mood
            exit_mood = await self.db.execute(
                select(MoodLog.mood, MoodLog.confidence)
                .where(MoodLog.visit_id == row.visit_id, MoodLog.zone == "exit")
                .order_by(MoodLog.timestamp.desc())
                .limit(1)
            )
            exit_mood_row = exit_mood.first()

            # Get cashier mood
            cashier_mood = await self.db.execute(
                select(MoodLog.mood, MoodLog.confidence)
                .where(MoodLog.visit_id == row.visit_id, MoodLog.zone == "cashier")
                .order_by(MoodLog.timestamp.desc())
                .limit(1)
            )
            cashier_mood_row = cashier_mood.first()

            details.append({
                "visitor_id": row.id,
                "person_uid": row.person_uid,
                "gender": row.gender or "unknown",
                "age_estimate": row.age_estimate,
                "age_group": row.age_group or "unknown",
                "entry_at": row.entry_at.isoformat() if row.entry_at else None,
                "exit_at": row.exit_at.isoformat() if row.exit_at else None,
                "dwell_seconds": row.dwell_seconds,
                "dwell_minutes": round(row.dwell_seconds / 60, 1) if row.dwell_seconds else None,
                "mood_entry": {
                    "mood": entry_mood_row.mood,
                    "confidence": round(entry_mood_row.confidence, 3),
                } if entry_mood_row else None,
                "mood_exit": {
                    "mood": exit_mood_row.mood,
                    "confidence": round(exit_mood_row.confidence, 3),
                } if exit_mood_row else None,
                "mood_cashier": {
                    "mood": cashier_mood_row.mood,
                    "confidence": round(cashier_mood_row.confidence, 3),
                } if cashier_mood_row else None,
            })

        return details
