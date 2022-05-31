module "aws_support_role" {
  count  = try(local.workspace.aws_support_role.enabled, false) ? 1 : 0
  source = "./aws-support-access-role"
}
