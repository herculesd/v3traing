locals {
  env       = yamldecode(file("./one.yaml"))
  workspace = local.env["workspaces"][terraform.workspace]
}

variable "aws_role" {
  default = "InfraDeployAccess"
}

provider "aws" {
  region = local.workspace.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${local.workspace.aws_account_id}:role/${var.aws_role}"
  }
}

locals {
  # Get SAML Provider ARN from baseline CF stack
  # or from an Existing ARN passed in the config
  saml_provider_arn = (
    local.workspace.saml_provider.get_from_baseline_cf_stack
    ) ? (
    data.aws_cloudformation_stack.baseline[0].outputs.IAMIdentityProviderArn
    ) : (
    local.workspace.saml_provider.existing_arn
  )
}
