
locals {
  ci_deploy_access_trust_arns = concat(
    [
      try(module.ci_deploy[0].ci_deploy_ec2_role_arn, ""),
      try(module.ci_deploy[0].ci_deploy_role_arn, ""),
      try(module.ci_deploy[0].ci_deploy_user_arn, ""),
    ],
    formatlist("arn:aws:iam::%s:root", local.workspace.ci_deploy_access.trust_account_ids),
    local.workspace.ci_deploy_access.trust_arns
  )
}

module "ci_deploy_access" {
  count  = local.workspace.ci_deploy_access.enabled ? 1 : 0
  source = "./ci-deploy-access-role"

  is_admin   = false
  trust_arns = compact(local.ci_deploy_access_trust_arns)
}

output "ci_deploy_access_role_arn" {
  value = try(module.ci_deploy_access[0].ci_deploy_access_role_arn, "")
}

module "ci_deploy" {
  count  = local.workspace.ci_deploy.enabled ? 1 : 0
  source = "./ci-deploy"

  create_user             = local.workspace.ci_deploy.create_user
  create_instance_profile = local.workspace.ci_deploy.create_instance_profile
  saml_provider_arn       = local.saml_provider_arn
}

output "ci_deploy_ec2_role_arn" {
  value = try(module.ci_deploy[0].ci_deploy_ec2_role_arn, "")
}
output "ci_deploy_instance_profile_arn" {
  value = try(module.ci_deploy[0].ci_deploy_instance_profile_arn, "")
}
output "ci_deploy_role_arn" {
  value = try(module.ci_deploy[0].ci_deploy_role_arn, "")
}
output "ci_deploy_saml_role" {
  value = try(module.ci_deploy[0].ci_deploy_saml_role, "")
}
output "ci_deploy_user_arn" {
  value = try(module.ci_deploy[0].ci_deploy_user_arn, "")
}