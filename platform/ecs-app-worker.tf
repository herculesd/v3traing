module "ecs_app_worker" {
  for_each = { for worker in local.workspace.ecs.workers : worker.name => worker }
  source   = "git::https://github.com/DNXLabs/terraform-aws-ecs-app-worker.git?ref=2.0.0"

  vpc_id           = module.network[0].vpc_id
  cluster_name     = each.value.cluster_name
  service_role_arn = module.ecs_cluster[each.value.cluster_name].ecs_service_iam_role_arn
  task_role_arn    = module.ecs_cluster[each.value.cluster_name].ecs_task_iam_role_arn
  desired_count    = each.value.desired_count
  cpu              = each.value.cpu
  memory           = each.value.memory

  name                                    = each.value.name
  alarm_sns_topics                        = try([local.workspace.notifications_sns_topic_arn], [])
  cloudwatch_logs_export                  = each.value.cloudwatch_logs_export
  log_subscription_filter_enabled         = false
  log_subscription_filter_role_arn        = ""
  log_subscription_filter_destination_arn = ""

  launch_type     = try(each.value.launch_type, "EC2")
  fargate_spot    = try(each.value.fargate_spot, false)
  network_mode    = try(each.value.launch_type, "EC2") == "FARGATE" ? "awsvpc" : null
  security_groups = try(each.value.launch_type, "EC2") == "FARGATE" ? [module.ecs_cluster[each.value.cluster_name].ecs_nodes_secgrp_id] : null
  subnets         = try(each.value.launch_type, "EC2") == "FARGATE" ? module.network[0].private_subnet_ids[0] : null
}