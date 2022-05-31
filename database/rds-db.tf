module "rds_db" {
  for_each             = { for db in local.workspace.rds.dbs : db.name => db }
  source               = "git::https://github.com/DNXLabs/terraform-aws-rds.git?ref=0.3.3"
  db_type              = "rds"
  
  name                  = each.value.name
  environment_name      = each.value.environment_name
  user                  = each.value.user
  retention             = each.value.retention
  instance_class        = each.value.instance_class
  engine                = each.value.engine
  engine_version        = each.value.engine_version
  port                  = each.value.port
  parameter_group_name  = each.value.parameter_group_name
  allocated_storage     = each.value.allocated_storage
  max_allocated_storage = try(each.value.max_allocated_storage, 0)
  apply_immediately     = each.value.apply_immediately
  snapshot_identifier   = each.value.snapshot_identifier
  storage_encrypted     = each.value.storage_encrypted
  kms_key_arn           = try(each.value.kms_key_arn, "")
  backup                = each.value.backup
  skip_final_snapshot   = each.value.skip_final_snapshot
  multi_az              = each.value.multi_az

  allow_security_group_ids = concat(
    [try(data.aws_security_group.eks_sg[0].id, [])],  # Trusts the EKS Cluster
    [try(data.aws_security_group.vpn_sg.id, [])]   # Trusts the local VPN
  )

  allow_cidrs        = try(each.value.allow_cidrs, [])
  vpc_id             = data.aws_vpc.selected.id
  db_subnet_group_id = data.aws_db_subnet_group.default.id
}

module "rds_scheduler" {
  for_each   = { for db in local.workspace.rds.dbs : db.name => db if db.shutdown_schedule.enabled }
  source     = "git::https://github.com/DNXLabs/terraform-aws-rds-scheduler.git?ref=1.0.2"
  enable     = each.value.shutdown_schedule.enabled
  identifier = module.rds_db[each.key].identifier
  cron_stop  = each.value.shutdown_schedule.cron_stop
  cron_start = each.value.shutdown_schedule.cron_start
}

module "rds_monitoring" {
  for_each         = { for db in local.workspace.rds.dbs : db.name => db if db.notifications_sns.enabled }
  source           = "git::https://github.com/DNXLabs/terraform-aws-db-monitoring.git?ref=1.2.0"
  identifier       = module.rds_db[each.key].identifier
  account_name     = terraform.workspace
  instance_class   = each.value.instance_class
  alarm_sns_topics = try([local.workspace.notifications_sns_topic_arn], [])
}
