resource "aws_iam_service_linked_role" "ecs" {
  count            = local.workspace.ecs.create_iam_service_linked_role ? 1 : 0
  aws_service_name = "ecs.amazonaws.com"
}

module "ecs_cluster" {
  for_each = { for cluster in local.workspace.ecs.clusters : cluster.name => cluster }
  source   = "git::https://github.com/DNXLabs/terraform-aws-ecs.git?ref=5.6.0"

  name                 = each.value.name
  instance_types       = try(each.value.instance_types, [])
  instance_volume_size = try(each.value.instance_volume_size, 40)
  architecture         = try(each.value.architecture, "x86_64")
  fargate_only         = each.value.fargate_only
  kms_key_arn          = try(each.value.kms_key_arn, "")

  vpc_id             = module.network[0].vpc_id
  private_subnet_ids = module.network[0].private_subnet_ids[0]
  public_subnet_ids  = module.network[0].public_subnet_ids[0]
  secure_subnet_ids  = module.network[0].secure_subnet_ids[0]

  certificate_arn        = can(each.value.certificate) ? module.acm_certificate[each.value.certificate].arn : try(each.value.certificate_arn, "")
  extra_certificate_arns = try(each.value.extra_certificate_arns, [])

  on_demand_percentage = try(each.value.on_demand_percentage, 100)
  asg_min              = try(each.value.asg_min, 1)
  asg_max              = try(each.value.asg_max, 8)
  asg_target_capacity  = try(each.value.asg_target_capacity, 70)

  alarm_sns_topics                    = try([local.workspace.notifications_sns_topic_arn], [])
  alarm_alb_latency_anomaly_threshold = try(each.value.alarm_alb_latency_anomaly_threshold, 0)
  alarm_prefix                        = terraform.workspace

  alb_only                                = true # prevents creating cloudfront - see terraform-aws-ecs-app-front
  alb                                     = try(each.value.alb, true)
  alb_http_listener                       = try(each.value.alb_http_listener, true)
  alb_sg_allow_test_listener              = try(each.value.alb_sg_allow_test_listener, true)
  alb_enable_deletion_protection          = try(each.value.alb_enable_deletion_protection, false)
  alb_ssl_policy                          = try(each.value.alb_ssl_policy, "ELBSecurityPolicy-TLS-1-2-2017-01")
  wafv2_enable                            = true
  security_group_ecs_nodes_outbound_cidrs = ["0.0.0.0/0"]
  lb_access_logs_bucket                   = try(each.value.lb_access_logs_bucket, "")
  lb_access_logs_prefix                   = ""

  enable_schedule     = try(each.value.shutdown_schedule.enabled, false)
  schedule_cron_start = try(each.value.shutdown_schedule.cron_start, "")
  schedule_cron_stop  = try(each.value.shutdown_schedule.cron_stop, "")

  backup = try(each.value.efs_backup, false)
}
