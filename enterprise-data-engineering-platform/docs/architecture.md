# Platform Architecture

## Overview
An enterprise batch data platform: raw data lands in S3, is validated and
transformed with Spark (EMR), then loaded into Snowflake for analytics.
Airflow orchestrates the flow; Terraform provisions all AWS infrastructure;
CloudWatch + Prometheus provide observability.

## Data flow
```
Source ─▶ S3 raw ─▶ validation ─▶ Spark (EMR) ─▶ S3 processed ─▶ Snowflake ─▶ BI / marts
          (Airflow orchestrates every hop)
```

## Layers
| Layer | Store | Purpose |
|-------|-------|---------|
| Raw | `s3://edp-<env>-raw` | Immutable landing zone, partitioned by ingest date |
| Processed | `s3://edp-<env>-processed` | Cleaned, typed, deduped Parquet |
| Curated | `s3://edp-<env>-curated` | Business-ready datasets |
| Warehouse | Snowflake `ANALYTICS` | Staging → warehouse → marts → analytics |

## Environments
`dev`, `stage`, `prod` — isolated VPCs and state, promoted via the same
Terraform root with per-env `terraform.tfvars` + `backend.hcl`.

## Infrastructure modules
`networking`, `s3`, `iam`, `ec2`, `emr`, `cloudwatch` — see [terraform/modules](../terraform/modules).

## Snowflake integration
S3 external stages authenticate via a dedicated IAM role (see the `iam`
module + `sql/warehouse/setup.sql`). Trust is scoped with the Snowflake
principal ARN + external ID from `DESC INTEGRATION`.
