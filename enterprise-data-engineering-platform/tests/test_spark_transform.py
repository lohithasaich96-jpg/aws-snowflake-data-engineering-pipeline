import pytest

pyspark = pytest.importorskip("pyspark")

from pyspark.sql import SparkSession  # noqa: E402

from src.spark.sales_transform import transform  # noqa: E402


@pytest.fixture(scope="module")
def spark():
    s = SparkSession.builder.master("local[1]").appName("test").getOrCreate()
    yield s
    s.stop()


def test_transform_computes_gross_and_dedups(spark):
    rows = [
        ("o1", "c1", "p1", "2", "10.0", "2026-01-01T10:00:00"),
        ("o1", "c1", "p1", "2", "10.0", "2026-01-01T10:00:00"),  # dup
        ("o2", "c2", "p2", "1", "5.5", "2026-01-02T12:00:00"),
    ]
    cols = ["order_id", "customer_id", "product_id", "quantity", "unit_price", "order_ts"]
    df = spark.createDataFrame(rows, cols)

    out = transform(df).collect()
    assert len(out) == 2
    by_id = {r["order_id"]: r for r in out}
    assert by_id["o1"]["gross_amount"] == 20.0
