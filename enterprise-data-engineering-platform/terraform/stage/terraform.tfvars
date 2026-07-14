environment             = "stage"
aws_region              = "us-east-1"
project_name            = "edp"
vpc_cidr                = "10.20.0.0/16"
enable_nat_gateway      = true
instance_type           = "t3.medium"
enable_emr              = false
emr_core_instance_count = 2
enable_snowflake_role   = true
# snowflake_iam_principal_arn = "arn:aws:iam::<snowflake-acct>:user/xxxx"
# snowflake_external_id       = "XXXX_SFCRole=..."
# alert_email                 = "data-oncall@example.com"
