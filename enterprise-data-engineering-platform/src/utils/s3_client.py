"""Thin boto3 S3 helpers used by ingestion and loaders."""

from __future__ import annotations

from typing import Iterator

import boto3

from src.common.logging_config import get_logger

log = get_logger(__name__)


def get_s3(region: str = "us-east-1"):
    return boto3.client("s3", region_name=region)


def upload_file(local_path: str, bucket: str, key: str, region: str = "us-east-1") -> str:
    get_s3(region).upload_file(local_path, bucket, key)
    uri = f"s3://{bucket}/{key}"
    log.info("uploaded %s", uri)
    return uri


def list_keys(bucket: str, prefix: str, region: str = "us-east-1") -> Iterator[str]:
    paginator = get_s3(region).get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            yield obj["Key"]
