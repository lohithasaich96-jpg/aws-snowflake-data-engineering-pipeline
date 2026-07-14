# EMR cluster for Spark batch processing. Kept small/transient by default.

resource "aws_emr_cluster" "this" {
  name          = "${var.name_prefix}-emr"
  release_label = var.release_label
  applications  = var.applications
  log_uri       = var.log_uri

  service_role = var.service_role_arn

  ec2_attributes {
    subnet_id                         = var.subnet_id
    instance_profile                  = var.instance_profile_name
    emr_managed_master_security_group = var.master_sg_id
    emr_managed_slave_security_group  = var.slave_sg_id
    key_name                          = var.key_name
  }

  master_instance_group {
    instance_type  = var.master_instance_type
    instance_count = 1
  }

  core_instance_group {
    instance_type  = var.core_instance_type
    instance_count = var.core_instance_count
  }

  configurations_json = jsonencode([
    {
      Classification = "spark-defaults"
      Properties = {
        "spark.dynamicAllocation.enabled" = "true"
      }
    }
  ])

  tags = merge(var.tags, { Name = "${var.name_prefix}-emr" })
}
