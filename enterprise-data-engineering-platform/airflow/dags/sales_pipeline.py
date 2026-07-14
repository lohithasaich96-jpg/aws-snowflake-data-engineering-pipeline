"""Sales data pipeline: S3 ingest -> validate -> Spark transform -> Snowflake load.

This DAG orchestrates the end-to-end batch flow for the sales domain. Task
implementations live under ``src/`` and are imported here so the DAG stays a
thin orchestration layer.
"""

from __future__ import annotations

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator

default_args = {
    "owner": "data-engineering",
    "depends_on_past": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "email_on_failure": True,
}


def _ingest(**context) -> str:
    from src.ingestion.s3_ingest import ingest_sales

    return ingest_sales(execution_date=context["ds"])


def _validate(**context) -> None:
    from src.validation.schema_checks import validate_sales

    validate_sales(execution_date=context["ds"])


def _transform(**context) -> None:
    from src.spark.sales_transform import run

    run(execution_date=context["ds"])


def _load_snowflake(**context) -> None:
    from src.snowflake.loader import load_curated

    load_curated(table="FCT_SALES", execution_date=context["ds"])


with DAG(
    dag_id="sales_pipeline",
    description="Daily sales batch: ingest, validate, transform, load to Snowflake",
    schedule="0 2 * * *",
    start_date=datetime(2026, 1, 1),
    catchup=False,
    max_active_runs=1,
    default_args=default_args,
    tags=["sales", "batch", "snowflake"],
) as dag:
    start = EmptyOperator(task_id="start")

    ingest = PythonOperator(task_id="ingest_raw", python_callable=_ingest)
    validate = PythonOperator(task_id="validate", python_callable=_validate)
    transform = PythonOperator(task_id="spark_transform", python_callable=_transform)
    load = PythonOperator(task_id="load_snowflake", python_callable=_load_snowflake)

    end = EmptyOperator(task_id="end")

    start >> ingest >> validate >> transform >> load >> end
