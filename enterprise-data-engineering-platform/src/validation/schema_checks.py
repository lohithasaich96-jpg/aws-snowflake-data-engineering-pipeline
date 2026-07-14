"""Data-quality checks run between ingest and transform.

Uses lightweight, dependency-free rules so it can run anywhere. Swap in
Great Expectations / Pandera for richer suites without changing the DAG.
"""

from __future__ import annotations

from dataclasses import dataclass

from src.common.logging_config import get_logger

log = get_logger(__name__)

EXPECTED_COLUMNS = {"order_id", "customer_id", "product_id", "quantity", "unit_price", "order_ts"}


@dataclass
class ValidationResult:
    passed: bool
    errors: list[str]


def validate_records(records: list[dict]) -> ValidationResult:
    errors: list[str] = []
    for i, rec in enumerate(records):
        missing = EXPECTED_COLUMNS - rec.keys()
        if missing:
            errors.append(f"row {i}: missing columns {sorted(missing)}")
        if rec.get("quantity", 0) <= 0:
            errors.append(f"row {i}: quantity must be > 0")
        if rec.get("unit_price", 0) < 0:
            errors.append(f"row {i}: unit_price must be >= 0")
    return ValidationResult(passed=not errors, errors=errors)


def validate_sales(execution_date: str) -> None:
    """Validate the day's raw sales partition; raise on failure to fail the task."""
    log.info("validating sales partition dt=%s", execution_date)
    # TODO: read the raw partition and run validate_records over it.
    result = validate_records([])
    if not result.passed:
        raise ValueError(f"validation failed: {result.errors}")
