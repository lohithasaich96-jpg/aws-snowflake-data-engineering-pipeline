from src.validation.schema_checks import validate_records


def _valid_record():
    return {
        "order_id": "o1",
        "customer_id": "c1",
        "product_id": "p1",
        "quantity": 2,
        "unit_price": 9.99,
        "order_ts": "2026-01-01T00:00:00",
    }


def test_valid_record_passes():
    assert validate_records([_valid_record()]).passed


def test_missing_column_fails():
    rec = _valid_record()
    del rec["customer_id"]
    result = validate_records([rec])
    assert not result.passed
    assert any("missing columns" in e for e in result.errors)


def test_nonpositive_quantity_fails():
    rec = _valid_record()
    rec["quantity"] = 0
    assert not validate_records([rec]).passed
