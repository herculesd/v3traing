module "wafv2_setup" {
  count  = local.workspace.wafv2.enabled ? 1 : 0
  source = "./wafv2-setup"

  name                            = local.workspace.eks.name
  wafv2_enable                    = local.workspace.wafv2.enabled
  wafv2_managed_rule_groups       = local.workspace.wafv2.managed_rule_groups
  wafv2_managed_block_rule_groups = local.workspace.wafv2.managed_block_rule_groups
  wafv2_rate_limit_rule           = local.workspace.wafv2.rate_limit_rule
  wafv2_cloudwatch_logging        = local.workspace.wafv2.cloudwatch_logging
  wafv2_cloudwatch_retention      = local.workspace.wafv2.cloudwatch_retention
  wafv2_create_alb_association    = try(local.workspace.wafv2.create_alb_association, false)
  wafv2_arn_alb_internet_facing   = try(local.workspace.wafv2.arn_alb_internet_facing, "")
}
