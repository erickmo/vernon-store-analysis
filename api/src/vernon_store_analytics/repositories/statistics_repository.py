"""
Repository untuk store statistics dan customer behavior analytics.
Query-query aggregasi lanjutan yang tidak ada di analytics_repository.
"""

from datetime import datetime

from sqlalchemy import Float, Integer, String, and_, case, cast, distinct, func, literal, select, text
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.db.detection_log import DetectionLog
from ..models.db.mood_log import MoodLog
from ..models.db.visit import Visit
from ..models.db.visitor import Visitor


class StatisticsRepository:
    """Data access layer untuk advanced store statistics."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    # ── Conversion & Bounce ───────────────────────────────────

    async def get_conversion_rate(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """
        Conversion rate = visitors yang ke kasir / total visitors.
        Mengukur berapa persen pengunjung yang melakukan transaksi.
        """
        # Total unique visitors
        total_q = await self.db.execute(
            select(func.count(distinct(Visit.visitor_id)))
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(Visitor.store_id == store_id, Visit.entry_at >= start, Visit.entry_at <= end)
        )
        total = total_q.scalar_one()

        # Visitors yang ke kasir
        cashier_q = await self.db.execute(
            select(func.count(distinct(MoodLog.visit_id)))
            .join(Visit, MoodLog.visit_id == Visit.id)
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                MoodLog.zone == "cashier",
                MoodLog.timestamp >= start,
                MoodLog.timestamp <= end,
            )
        )
        cashier_visitors = cashier_q.scalar_one()

        rate = round(cashier_visitors / total * 100, 1) if total > 0 else 0
        return {
            "total_visitors": total,
            "cashier_visitors": cashier_visitors,
            "conversion_rate": rate,
            "non_converting": total - cashier_visitors,
        }

    async def get_bounce_rate(
        self, store_id: int, start: datetime, end: datetime, threshold_seconds: int = 120
    ) -> dict:
        """
        Bounce rate = visitors yang pergi dalam < threshold detik / total.
        Default threshold: 2 menit.
        """
        total_q = await self.db.execute(
            select(func.count(Visit.id))
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start, Visit.entry_at <= end,
                Visit.dwell_seconds.isnot(None),
            )
        )
        total = total_q.scalar_one()

        bounce_q = await self.db.execute(
            select(func.count(Visit.id))
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start, Visit.entry_at <= end,
                Visit.dwell_seconds.isnot(None),
                Visit.dwell_seconds < threshold_seconds,
            )
        )
        bounced = bounce_q.scalar_one()

        rate = round(bounced / total * 100, 1) if total > 0 else 0
        return {
            "total_visits": total,
            "bounced_visits": bounced,
            "bounce_rate": rate,
            "threshold_seconds": threshold_seconds,
        }

    # ── Return Visitors ───────────────────────────────────────

    async def get_return_visitor_stats(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """Statistik visitor yang datang lebih dari sekali."""
        result = await self.db.execute(
            select(
                Visitor.id,
                Visitor.total_visits,
            )
            .join(Visit, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start, Visit.entry_at <= end,
            )
            .group_by(Visitor.id, Visitor.total_visits)
        )
        rows = result.all()
        total = len(rows)
        new_visitors = sum(1 for r in rows if r.total_visits <= 1)
        returning = sum(1 for r in rows if r.total_visits > 1)

        return {
            "total_unique_visitors": total,
            "new_visitors": new_visitors,
            "returning_visitors": returning,
            "return_rate": round(returning / total * 100, 1) if total > 0 else 0,
            "new_rate": round(new_visitors / total * 100, 1) if total > 0 else 0,
        }

    # ── Customer Journey / Zone Flow ──────────────────────────

    async def get_zone_flow(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        """
        Analisis alur perjalanan customer di store.
        Menghitung berapa visitor yang mengikuti pola tertentu.
        """
        # Get zone sequence per visit
        result = await self.db.execute(
            select(
                MoodLog.visit_id,
                func.array_agg(
                    MoodLog.zone.op("ORDER BY")(MoodLog.timestamp)
                ).label("zones"),
            )
            .join(Visit, MoodLog.visit_id == Visit.id)
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                MoodLog.timestamp >= start, MoodLog.timestamp <= end,
            )
            .group_by(MoodLog.visit_id)
        )
        rows = result.all()

        # Categorize journeys
        patterns: dict[str, int] = {}
        for row in rows:
            zones = row.zones if row.zones else []
            # Deduplicate consecutive same zones
            deduped = []
            for z in zones:
                if not deduped or deduped[-1] != z:
                    deduped.append(z)
            pattern = " → ".join(deduped)
            patterns[pattern] = patterns.get(pattern, 0) + 1

        total = len(rows)
        sorted_patterns = sorted(patterns.items(), key=lambda x: x[1], reverse=True)

        return [
            {
                "journey": p,
                "count": c,
                "percentage": round(c / total * 100, 1) if total > 0 else 0,
            }
            for p, c in sorted_patterns[:15]  # top 15 patterns
        ]

    # ── Mood Shift (Entry vs Exit) ────────────────────────────

    async def get_mood_shift(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """
        Analisis perubahan mood dari entry ke exit.
        Apakah customer keluar lebih happy atau lebih unhappy?
        """
        # Mood values for scoring: higher = more positive
        mood_score_map = {
            "happy": 3, "surprise": 2, "neutral": 1,
            "sad": -1, "fear": -2, "angry": -2, "disgust": -3,
        }

        # Get entry moods (first per visit)
        entry_sub = (
            select(
                MoodLog.visit_id,
                MoodLog.mood,
                func.row_number().over(
                    partition_by=MoodLog.visit_id,
                    order_by=MoodLog.timestamp.asc()
                ).label("rn"),
            )
            .join(Visit, MoodLog.visit_id == Visit.id)
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                MoodLog.zone == "entry",
                MoodLog.timestamp >= start, MoodLog.timestamp <= end,
            )
            .subquery()
        )
        entry_result = await self.db.execute(
            select(entry_sub.c.visit_id, entry_sub.c.mood)
            .where(entry_sub.c.rn == 1)
        )
        entry_moods = {r.visit_id: r.mood for r in entry_result.all()}

        # Get exit moods (last per visit)
        exit_sub = (
            select(
                MoodLog.visit_id,
                MoodLog.mood,
                func.row_number().over(
                    partition_by=MoodLog.visit_id,
                    order_by=MoodLog.timestamp.desc()
                ).label("rn"),
            )
            .join(Visit, MoodLog.visit_id == Visit.id)
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                MoodLog.zone == "exit",
                MoodLog.timestamp >= start, MoodLog.timestamp <= end,
            )
            .subquery()
        )
        exit_result = await self.db.execute(
            select(exit_sub.c.visit_id, exit_sub.c.mood)
            .where(exit_sub.c.rn == 1)
        )
        exit_moods = {r.visit_id: r.mood for r in exit_result.all()}

        # Compare
        improved = 0
        worsened = 0
        same = 0
        shifts = []

        common_visits = set(entry_moods.keys()) & set(exit_moods.keys())
        for vid in common_visits:
            e_mood = entry_moods[vid]
            x_mood = exit_moods[vid]
            e_score = mood_score_map.get(e_mood, 0)
            x_score = mood_score_map.get(x_mood, 0)

            if x_score > e_score:
                improved += 1
            elif x_score < e_score:
                worsened += 1
            else:
                same += 1

            shifts.append({"entry": e_mood, "exit": x_mood})

        total = len(common_visits)

        # Count shift transitions
        transition_counts: dict[str, int] = {}
        for s in shifts:
            key = f"{s['entry']} → {s['exit']}"
            transition_counts[key] = transition_counts.get(key, 0) + 1

        top_transitions = sorted(transition_counts.items(), key=lambda x: x[1], reverse=True)[:10]

        return {
            "total_comparable": total,
            "improved": improved,
            "worsened": worsened,
            "same": same,
            "improved_rate": round(improved / total * 100, 1) if total > 0 else 0,
            "worsened_rate": round(worsened / total * 100, 1) if total > 0 else 0,
            "satisfaction_score": round((improved - worsened) / total * 100, 1) if total > 0 else 0,
            "top_transitions": [
                {"transition": t, "count": c, "percentage": round(c / total * 100, 1) if total > 0 else 0}
                for t, c in top_transitions
            ],
        }

    # ── Demographics Cross-Tab ────────────────────────────────

    async def get_demographics_crosstab(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        """Gender x Age group cross-tabulation."""
        result = await self.db.execute(
            select(
                Visitor.gender,
                Visitor.age_group,
                func.count(distinct(Visitor.id)).label("count"),
                func.avg(Visit.dwell_seconds).label("avg_dwell"),
            )
            .join(Visit, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start, Visit.entry_at <= end,
            )
            .group_by(Visitor.gender, Visitor.age_group)
            .order_by(Visitor.gender, Visitor.age_group)
        )
        rows = result.all()
        total = sum(r.count for r in rows)
        return [
            {
                "gender": r.gender or "unknown",
                "age_group": r.age_group or "unknown",
                "count": r.count,
                "percentage": round(r.count / total * 100, 1) if total > 0 else 0,
                "avg_dwell_minutes": round(float(r.avg_dwell) / 60, 1) if r.avg_dwell else 0,
            }
            for r in rows
        ]

    # ── Dwell Time by Demographics ────────────────────────────

    async def get_dwell_by_gender(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        """Rata-rata dwell time per gender."""
        result = await self.db.execute(
            select(
                Visitor.gender,
                func.count(Visit.id).label("visits"),
                func.avg(Visit.dwell_seconds).label("avg_dwell"),
                func.min(Visit.dwell_seconds).label("min_dwell"),
                func.max(Visit.dwell_seconds).label("max_dwell"),
            )
            .join(Visit, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start, Visit.entry_at <= end,
                Visit.dwell_seconds.isnot(None),
            )
            .group_by(Visitor.gender)
        )
        return [
            {
                "gender": r.gender or "unknown",
                "visits": r.visits,
                "avg_dwell_minutes": round(float(r.avg_dwell) / 60, 1) if r.avg_dwell else 0,
                "min_dwell_minutes": round(r.min_dwell / 60, 1) if r.min_dwell else 0,
                "max_dwell_minutes": round(r.max_dwell / 60, 1) if r.max_dwell else 0,
            }
            for r in result.all()
        ]

    async def get_dwell_by_age_group(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        """Rata-rata dwell time per age group."""
        result = await self.db.execute(
            select(
                Visitor.age_group,
                func.count(Visit.id).label("visits"),
                func.avg(Visit.dwell_seconds).label("avg_dwell"),
            )
            .join(Visit, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start, Visit.entry_at <= end,
                Visit.dwell_seconds.isnot(None),
            )
            .group_by(Visitor.age_group)
            .order_by(func.avg(Visit.dwell_seconds).desc())
        )
        return [
            {
                "age_group": r.age_group or "unknown",
                "visits": r.visits,
                "avg_dwell_minutes": round(float(r.avg_dwell) / 60, 1) if r.avg_dwell else 0,
            }
            for r in result.all()
        ]

    # ── Zone Heatmap ──────────────────────────────────────────

    async def get_zone_heatmap(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        """Jumlah deteksi per zone — untuk heatmap visualisasi."""
        result = await self.db.execute(
            select(
                DetectionLog.zone,
                func.count().label("detections"),
                func.count(distinct(DetectionLog.visit_id)).label("unique_visitors"),
                func.avg(DetectionLog.mood_confidence).label("avg_mood_confidence"),
            )
            .join(Visit, DetectionLog.visit_id == Visit.id)
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                DetectionLog.timestamp >= start, DetectionLog.timestamp <= end,
            )
            .group_by(DetectionLog.zone)
            .order_by(func.count().desc())
        )
        rows = result.all()
        total_detections = sum(r.detections for r in rows)
        return [
            {
                "zone": r.zone,
                "detections": r.detections,
                "unique_visitors": r.unique_visitors,
                "traffic_share": round(r.detections / total_detections * 100, 1) if total_detections > 0 else 0,
                "avg_mood_confidence": round(float(r.avg_mood_confidence), 3) if r.avg_mood_confidence else 0,
            }
            for r in rows
        ]

    # ── Peak Hours ────────────────────────────────────────────

    async def get_peak_hours(
        self, store_id: int, start: datetime, end: datetime
    ) -> dict:
        """Analisis jam-jam tersibuk."""
        result = await self.db.execute(
            select(
                func.extract("hour", Visit.entry_at).label("hour"),
                func.count(distinct(Visit.visitor_id)).label("visitors"),
                func.avg(Visit.dwell_seconds).label("avg_dwell"),
            )
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                Visit.entry_at >= start, Visit.entry_at <= end,
            )
            .group_by("hour")
            .order_by("hour")
        )
        rows = result.all()

        hourly = [
            {
                "hour": int(r.hour),
                "hour_label": f"{int(r.hour):02d}:00",
                "visitors": r.visitors,
                "avg_dwell_minutes": round(float(r.avg_dwell) / 60, 1) if r.avg_dwell else 0,
            }
            for r in rows
        ]

        if hourly:
            peak = max(hourly, key=lambda x: x["visitors"])
            quiet = min(hourly, key=lambda x: x["visitors"])
        else:
            peak = quiet = None

        return {
            "hourly": hourly,
            "peak_hour": peak,
            "quietest_hour": quiet,
        }

    # ── Mood at Cashier by Demographics ───────────────────────

    async def get_cashier_mood_by_demographics(
        self, store_id: int, start: datetime, end: datetime
    ) -> list[dict]:
        """Mood di kasir breakdown per gender — siapa yang lebih happy/unhappy saat bayar?"""
        result = await self.db.execute(
            select(
                Visitor.gender,
                MoodLog.mood,
                func.count().label("count"),
            )
            .join(Visit, MoodLog.visit_id == Visit.id)
            .join(Visitor, Visit.visitor_id == Visitor.id)
            .where(
                Visitor.store_id == store_id,
                MoodLog.zone == "cashier",
                MoodLog.timestamp >= start, MoodLog.timestamp <= end,
            )
            .group_by(Visitor.gender, MoodLog.mood)
            .order_by(Visitor.gender, func.count().desc())
        )
        rows = result.all()

        # Group by gender
        by_gender: dict[str, list] = {}
        for r in rows:
            g = r.gender or "unknown"
            if g not in by_gender:
                by_gender[g] = []
            by_gender[g].append({"mood": r.mood, "count": r.count})

        output = []
        for gender, moods in by_gender.items():
            total = sum(m["count"] for m in moods)
            output.append({
                "gender": gender,
                "total_at_cashier": total,
                "moods": [
                    {**m, "percentage": round(m["count"] / total * 100, 1) if total > 0 else 0}
                    for m in moods
                ],
            })
        return output
