locals {
  name_prefix = "${var.project_name}-${var.environment}"
  account_id  = data.aws_caller_identity.current.account_id

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "networking" {
  source             = "./modules/networking"
  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  enable_nat_gateway = var.enable_nat_gateway
  tags               = local.common_tags
}

module "s3" {
  source      = "./modules/s3"
  name_prefix = local.name_prefix
  account_id  = local.account_id
  tags        = local.common_tags
}

module "iam" {
  source                      = "./modules/iam"
  name_prefix                 = local.name_prefix
  data_bucket_arns            = values(module.s3.bucket_arns)
  enable_snowflake_role       = var.enable_snowflake_role
  snowflake_iam_principal_arn = var.snowflake_iam_principal_arn
  snowflake_external_id       = var.snowflake_external_id
  tags                        = local.common_tags
}

module "ec2" {
  source                = "./modules/ec2"
  name_prefix           = local.name_prefix
  vpc_id                = module.networking.vpc_id
  subnet_id             = module.networking.public_subnet_ids[0]
  instance_type         = var.instance_type
  instance_profile_name = module.iam.ec2_instance_profile_name
  allowed_ssh_cidr      = var.allowed_ssh_cidr
  tags                  = local.common_tags
}

module "emr" {
  count                 = var.enable_emr ? 1 : 0
  source                = "./modules/emr"
  name_prefix           = local.name_prefix
  log_uri               = "s3://${module.s3.bucket_ids["logs"]}/emr-logs/"
  service_role_arn      = module.iam.emr_service_role_arn
  instance_profile_name = module.iam.emr_ec2_instance_profile_name
  subnet_id             = module.networking.public_subnet_ids[0]
  core_instance_count   = var.emr_core_instance_count
  tags                  = local.common_tags
}

module "cloudwatch" {
  source          = "./modules/cloudwatch"
  name_prefix     = local.name_prefix
  alert_email     = var.alert_email
  ec2_instance_id = module.ec2.instance_id
  tags            = local.common_tags
}
