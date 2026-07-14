# Enterprise Data Engineering Platform

Batch data platform on AWS + Snowflake, orchestrated by Airflow and provisioned
with Terraform. Raw data lands in S3, is validated and transformed with Spark on
EMR, and loaded into Snowflake for analytics.

```
├── terraform/      # IaC: modules + dev/stage/prod environments
├── airflow/        # DAGs + local docker-compose
├── src/            # Python: ingestion, validation, spark, snowflake, common, utils
├── sql/            # staging / warehouse / marts / analytics
├── tests/          # pytest unit tests
├── docker/         # job runtime image
├── config/         # non-secret per-env settings
├── monitoring/     # Prometheus + alert rules
├── docs/ architecture/   # design docs + diagrams
└── .github/workflows/    # CI/CD
```

## Architecture
See [docs/architecture.md](docs/architecture.md) and [architecture/data_flow.mmd](architecture/data_flow.mmd).

## Prerequisites
- Terraform >= 1.5, AWS CLI configured, Python 3.11, Docker
- An AWS account and (for the warehouse) a Snowflake account

## Quick start
```bash
make install                      # Python deps
make lint test                    # lint + unit tests
make airflow-up                   # local Airflow at http://localhost:8080 (admin/admin)
```

## Deploying infrastructure
State is stored remotely in S3 with DynamoDB locking. **Bootstrap the state
bucket + lock table once** (they can't live in the state they secure), fill in
the `CHANGE_ME` values in `terraform/<env>/backend.hcl`, then:

```bash
make tf-init  ENV=dev             # terraform init with the dev backend
make tf-plan  ENV=dev             # review the plan
make tf-apply ENV=dev             # create resources
make tf-destroy ENV=dev           # tear down
```

`dev` is free-tier friendly (no NAT, no EMR). `stage`/`prod` enable NAT, EMR,
and the Snowflake integration role — review costs before applying.

## Snowflake setup
1. `make tf-apply ENV=<env>` to create the storage-integration IAM role.
2. Run `sql/warehouse/setup.sql` (fill in the role ARN from the terraform output).
3. `DESC INTEGRATION S3_INT` → copy `STORAGE_AWS_IAM_USER_ARN` + `STORAGE_AWS_EXTERNAL_ID`
   into `terraform/<env>/terraform.tfvars` and re-apply to tighten the trust policy.
4. Deploy the staging/mart SQL and enable the `sales_pipeline` Airflow DAG.

## CI/CD
[.github/workflows/deploy.yml](.github/workflows/deploy.yml): lint + tests +
`terraform validate` on every PR; apply to prod on merge to `main` via OIDC
(no long-lived AWS keys).
