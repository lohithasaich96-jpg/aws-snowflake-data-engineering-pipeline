environment             = "prod"
aws_region              = "us-east-1"
project_name            = "edp"
vpc_cidr                = "10.30.0.0/16"
enable_nat_gateway      = true
instance_type           = "t3.large"
enable_emr              = true
emr_core_instance_count = 4
enable_snowflake_role   = true
# allowed_ssh_cidr            = "10.30.0.0/16"   # lock to VPN/bastion in prod
# snowflake_iam_principal_arn = "arn:aws:iam::<snowflake-acct>:user/xxxx"
# snowflake_external_id       = "XXXX_SFCRole=..."
# alert_email                 = "data-oncall@example.com"
