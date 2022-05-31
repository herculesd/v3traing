# Example app without CloudFront
module "ecs_app" {
  for_each = { for app in local.workspace.ecs.apps : app.name => app }
  source   = "git::https://github.com/DNXLabs/terraform-aws-ecs-app.git?ref=5.4.0"

  name           = each.value.name
  image          = try(each.value.image, "dnxsolutions/nginx-hello:latest")
  container_port = try(each.value.container_port, 80)
  port           = try(each.value.container_port, 80)
  protocol       = try(each.value.container_protocol, "HTTP")
  cpu            = each.value.cpu
  memory         = each.value.memory

  vpc_id                           = module.network[0].vpc_id
  cluster_name                     = each.value.cluster_name
  service_role_arn                 = module.ecs_cluster[each.value.cluster_name].ecs_service_iam_role_arn
  codedeploy_role_arn              = module.ecs_cluster[each.value.cluster_name].ecs_codedeploy_iam_role_arn
  create_iam_codedeployrole        = each.value.create_iam_codedeployrole
  task_role_arn                    = module.ecs_cluster[each.value.cluster_name].ecs_task_iam_role_arn
  alb_listener_https_arn           = element(module.ecs_cluster[each.value.cluster_name].alb_listener_https_arn, 0)
  test_traffic_route_listener_arn  = element(module.ecs_cluster[each.value.cluster_name].alb_listener_test_traffic_arn, 0)
  codedeploy_wait_time_for_cutover = 1440 # 24hrs max wait for cutover before automatically discarding deployment

  hostnames               = try(each.value.hostnames, [])
  hostname_redirects      = try(each.value.hostname_redirects, "")
  hostname_create         = try(each.value.hostname_create, false)
  alb_only                = true # cluster also need this option to disable ALB WAF
  alb_dns_name            = element(module.ecs_cluster[each.value.cluster_name].alb_dns_name, 0)
  hosted_zone_id          = try(aws_route53_zone.default[each.value.hosted_zone].zone_id, "")
  hosted_zone_is_internal = try(each.value.hosted_zone_is_internal, false)
  paths                   = try(each.value.paths, ["/*"])

  healthcheck_path                          = each.value.healthcheck_path
  service_health_check_grace_period_seconds = each.value.service_health_check_grace_period_seconds

  autoscaling_cpu = true
  autoscaling_min = each.value.autoscaling_min
  autoscaling_max = each.value.autoscaling_max

  alarm_sns_topics       = try([local.workspace.notifications_sns_topic_arn], [])
  cloudwatch_logs_export = each.value.cloudwatch_logs_export
  alarm_prefix           = terraform.workspace

  launch_type     = try(each.value.launch_type, "EC2")
  fargate_spot    = try(each.value.fargate_spot, false)
  network_mode    = try(each.value.launch_type, "EC2") == "FARGATE" ? "awsvpc" : null
  security_groups = try(each.value.launch_type, "EC2") == "FARGATE" ? [module.ecs_cluster[each.value.cluster_name].ecs_nodes_secgrp_id] : null
  subnets         = try(each.value.launch_type, "EC2") == "FARGATE" ? module.network[0].private_subnet_ids[0] : null

  efs_mapping      = try(each.value.efs_mapping_dir, "") != "" ? { module.ecs_cluster[each.value.cluster_name].efs_fs_id : try(each.value.efs_mapping_dir, "") } : {}
  ssm_variables    = try(each.value.ssm_variables, {})
  static_variables = try(each.value.static_variables, {})
}
