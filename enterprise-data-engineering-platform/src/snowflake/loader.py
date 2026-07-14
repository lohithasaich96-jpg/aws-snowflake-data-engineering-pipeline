"""Load curated Parquet from S3 into Snowflake via an external stage + COPY."""

from __future__ import annotations

import contextlib

from src.common.config import get_config
from src.common.logging_config import get_logger

log = get_logger(__name__)


@contextlib.contextmanager
def snowflake_connection():
    import snowflake.connector

    cfg = get_config().snowflake
    conn = snowflake.connector.connect(
        account=cfg.account,
        user=cfg.user,
        password=cfg.password,
        role=cfg.role,
        warehouse=cfg.warehouse,
        database=cfg.database,
        schema=cfg.schema,
    )
    try:
        yield conn
    finally:
        conn.close()


def load_curated(table: str, execution_date: str, stage: str = "SALES_STAGE") -> None:
    """COPY the day's partition from the external stage into ``table``."""
    cfg = get_config()
    path = f"sales/dt={execution_date}/"
    copy_sql = f"""
        COPY INTO {cfg.snowflake.database}.{cfg.snowflake.schema}.{table}
        FROM @{stage}/{path}
        FILE_FORMAT = (TYPE = PARQUET)
        MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
        ON_ERROR = ABORT_STATEMENT
    """
    log.info("loading %s from @%s/%s", table, stage, path)
    with snowflake_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(copy_sql)
            log.info("COPY result: %s", cur.fetchall())
