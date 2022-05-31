module "job_function_roles" {
  count                = local.workspace.job_function_roles.enabled ? 1 : 0
  source               = "./job-function-roles"
  create_default_roles = try(local.workspace.job_function_roles.create_default_roles, false)
  saml_provider_arn    = local.saml_provider_arn
}

output "job_function_roles" {
  value = try(module.job_function_roles[0], {})
}
