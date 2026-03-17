"""TestReporter — helper standar untuk mencetak metadata test."""

from __future__ import annotations

import textwrap


class TestReporter:
    """
    Mencetak skenario, goal, flow, result, dan status untuk setiap test.

    Usage:
        def test_create_user(test_reporter):
            test_reporter.scenario("User baru dengan email valid")
            test_reporter.goal("User tersimpan di database")
            test_reporter.flow("POST /users → service.create → repo.save → return 201")

            # test assertions...

            test_reporter.result("User berhasil dibuat dengan ID auto-generated")
    """

    SEP = "─" * 60
    SEP_THICK = "═" * 60

    def __init__(self, test_name: str) -> None:
        self._name = test_name
        self._scenario = "—"
        self._goal = "—"
        self._flow = "—"
        self._result = "—"

        print(f"\n{self.SEP}")
        print(f"TEST     : {self._name}")

    def scenario(self, text: str) -> TestReporter:
        """Mencetak deskripsi skenario test."""
        self._scenario = text
        print(f"Scenario : {text}")
        return self

    def goal(self, text: str) -> TestReporter:
        """Mencetak tujuan test."""
        self._goal = text
        print(f"Goal     : {text}")
        return self

    def flow(self, text: str) -> TestReporter:
        """Mencetak alur test step-by-step."""
        self._flow = text
        wrapped = textwrap.fill(text, width=55, subsequent_indent=" " * 11)
        print(f"Flow     : {wrapped}")
        return self

    def result(self, text: str) -> TestReporter:
        """Mencetak hasil aktual test."""
        self._result = text
        return self

    def finalize(self, outcome: str) -> None:
        """Mencetak result dan status akhir."""
        status_map = {
            "passed": "✅ PASSED",
            "failed": "❌ FAILED",
            "skipped": "⚠️  SKIPPED",
        }
        status = status_map.get(outcome, "❓ UNKNOWN")

        if self._result == "—" and outcome == "passed":
            self._result = "Semua assertion terpenuhi"
        elif self._result == "—" and outcome == "failed":
            self._result = "Ada assertion yang gagal — lihat traceback"

        print(f"Result   : {self._result}")
        print(f"Status   : {status}")


class SuiteSummary:
    """Mencetak ringkasan suite setelah semua test selesai."""

    def __init__(
        self,
        name: str,
        total: int,
        passed: int,
        failed: int,
        skipped: int,
    ) -> None:
        self.name = name
        self.total = total
        self.passed = passed
        self.failed = failed
        self.skipped = skipped

    def print(self) -> None:
        sep = "═" * 60
        print(f"\n{sep}")
        print(f"SUITE    : {self.name}")
        print(f"  Total   : {self.total}")
        print(f"  ✅ Passed : {self.passed}")
        print(f"  ❌ Failed : {self.failed}")
        print(f"  ⚠️  Skipped: {self.skipped}")
        print(f"{sep}\n")
