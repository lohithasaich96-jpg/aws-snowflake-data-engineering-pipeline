"""PySpark job: raw sales -> cleaned, enriched fact rows in the processed layer.

Run locally with ``spark-submit`` or submit as an EMR step. Reads the raw
partition, applies typing/dedup/derivations, writes partitioned Parquet.
"""

from __future__ import annotations

import argparse

from src.common.config import get_config
from src.common.logging_config import get_logger

log = get_logger(__name__)


def build_spark(app_name: str = "sales_transform"):
    from pyspark.sql import SparkSession

    return (
        SparkSession.builder.appName(app_name)
        .config("spark.sql.parquet.compression.codec", "snappy")
        .getOrCreate()
    )


def transform(df):
    from pyspark.sql import functions as F

    return (
        df.dropDuplicates(["order_id"])
        .withColumn("quantity", F.col("quantity").cast("int"))
        .withColumn("unit_price", F.col("unit_price").cast("double"))
        .withColumn("gross_amount", F.col("quantity") * F.col("unit_price"))
        .withColumn("order_date", F.to_date("order_ts"))
        .filter(F.col("quantity") > 0)
    )


def run(execution_date: str) -> None:
    cfg = get_config()
    src_uri = f"s3a://{cfg.s3.raw_bucket}/sales/dt={execution_date}/"
    dst_uri = f"s3a://{cfg.s3.processed_bucket}/sales/dt={execution_date}/"

    log.info("spark transform %s -> %s", src_uri, dst_uri)
    spark = build_spark()
    try:
        df = spark.read.json(src_uri)
        out = transform(df)
        out.write.mode("overwrite").partitionBy("order_date").parquet(dst_uri)
        log.info("wrote %d rows", out.count())
    finally:
        spark.stop()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--execution-date", required=True)
    args = parser.parse_args()
    run(args.execution_date)
