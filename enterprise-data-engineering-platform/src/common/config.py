"""Central configuration loaded from environment variables / YAML.

Keeps secrets out of code: everything comes from the environment (populated
from AWS Secrets Manager / SSM in real deployments), with sane local defaults.
"""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from functools import lru_cache


@dataclass(frozen=True)
class S3Config:
    raw_bucket: str = field(default_factory=lambda: os.getenv("S3_RAW_BUCKET", "edp-dev-raw"))
    processed_bucket: str = field(default_factory=lambda: os.getenv("S3_PROCESSED_BUCKET", "edp-dev-processed"))
    curated_bucket: str = field(default_factory=lambda: os.getenv("S3_CURATED_BUCKET", "edp-dev-curated"))


@dataclass(frozen=True)
class SnowflakeConfig:
    account: str = field(default_factory=lambda: os.getenv("SNOWFLAKE_ACCOUNT", ""))
    user: str = field(default_factory=lambda: os.getenv("SNOWFLAKE_USER", ""))
    password: str = field(default_factory=lambda: os.getenv("SNOWFLAKE_PASSWORD", ""))
    role: str = field(default_factory=lambda: os.getenv("SNOWFLAKE_ROLE", "SYSADMIN"))
    warehouse: str = field(default_factory=lambda: os.getenv("SNOWFLAKE_WAREHOUSE", "COMPUTE_WH"))
    database: str = field(default_factory=lambda: os.getenv("SNOWFLAKE_DATABASE", "ANALYTICS"))
    schema: str = field(default_factory=lambda: os.getenv("SNOWFLAKE_SCHEMA", "PUBLIC"))


@dataclass(frozen=True)
class AppConfig:
    env: str = field(default_factory=lambda: os.getenv("APP_ENV", "dev"))
    aws_region: str = field(default_factory=lambda: os.getenv("AWS_REGION", "us-east-1"))
    s3: S3Config = field(default_factory=S3Config)
    snowflake: SnowflakeConfig = field(default_factory=SnowflakeConfig)


@lru_cache(maxsize=1)
def get_config() -> AppConfig:
    """Return the process-wide application config (memoized)."""
    return AppConfig()
