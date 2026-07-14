"""Land raw sales data into the S3 raw layer, partitioned by ingest date."""

from __future__ import annotations

from src.common.config import get_config
from src.common.logging_config import get_logger

log = get_logger(__name__)


def ingest_sales(execution_date: str, source_path: str | None = None) -> str:
    """Copy source extract into s3://<raw>/sales/dt=<execution_date>/.

    Returns the destination S3 prefix. In a real deployment ``source_path``
    would point at an SFTP drop / API extract; here it is a placeholder so the
    DAG wiring is exercised end-to-end.
    """
    cfg = get_config()
    dest_prefix = f"sales/dt={execution_date}/"
    dest_uri = f"s3://{cfg.s3.raw_bucket}/{dest_prefix}"

    log.info("ingesting sales for %s -> %s (source=%s)", execution_date, dest_uri, source_path)
    # TODO: pull from real source and upload via src.utils.s3_client.upload_file
    return dest_uri
