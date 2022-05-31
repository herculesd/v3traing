data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_cloudformation_stack" "baseline" {
  count = local.workspace.saml_provider.get_from_baseline_cf_stack ? 1 : 0
  name  = try(local.workspace.baseline_cf_stack_name, "")
}