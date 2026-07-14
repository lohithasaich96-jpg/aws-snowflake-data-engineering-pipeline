-- One-time warehouse/database/schema/stage bootstrap for the platform.
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
    WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE INITIALLY_SUSPENDED = TRUE;

CREATE DATABASE IF NOT EXISTS ANALYTICS;
CREATE SCHEMA IF NOT EXISTS ANALYTICS.STAGING;
CREATE SCHEMA IF NOT EXISTS ANALYTICS.WAREHOUSE;
CREATE SCHEMA IF NOT EXISTS ANALYTICS.MARTS;

-- Storage integration binds Snowflake to the IAM role created in terraform/modules/iam.
CREATE STORAGE INTEGRATION IF NOT EXISTS S3_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = '<snowflake_role_arn from terraform output>'
    STORAGE_ALLOWED_LOCATIONS = ('s3://edp-prod-processed-<acct>/', 's3://edp-prod-curated-<acct>/');

-- After DESC INTEGRATION S3_INT, copy STORAGE_AWS_IAM_USER_ARN + STORAGE_AWS_EXTERNAL_ID
-- back into terraform.tfvars (snowflake_iam_principal_arn / snowflake_external_id) and re-apply.

CREATE STAGE IF NOT EXISTS ANALYTICS.STAGING.SALES_STAGE
    STORAGE_INTEGRATION = S3_INT
    URL = 's3://edp-prod-processed-<acct>/sales/'
    FILE_FORMAT = (TYPE = PARQUET);
