"""Shared fixtures dan konfigurasi pytest untuk seluruh test suite."""

import pytest
from tests.testutil.reporter import TestReporter


@pytest.fixture(autouse=True)
def test_reporter(request: pytest.FixtureRequest) -> TestReporter:
    """
    Fixture yang otomatis inject TestReporter ke setiap test.
    Mencetak hasil akhir (PASSED/FAILED/SKIPPED) setelah test selesai.
    """
    reporter = TestReporter(request.node.name)
    yield reporter

    outcome = "unknown"
    if hasattr(request.node, "rep_call"):
        if request.node.rep_call.passed:
            outcome = "passed"
        elif request.node.rep_call.failed:
            outcome = "failed"
        elif request.node.rep_call.skipped:
            outcome = "skipped"

    reporter.finalize(outcome)


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item: pytest.Item, call: pytest.CallInfo) -> None:
    """Hook untuk menyimpan hasil test ke node agar bisa diakses di fixture."""
    outcome = yield
    rep = outcome.get_result()
    setattr(item, f"rep_{rep.when}", rep)
