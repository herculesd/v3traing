variable "aws_role" {
  default = "InfraDeployAccess"
}

provider "aws" {
  region = local.workspace.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${local.workspace.aws_account_id}:role/${var.aws_role}"
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::${local.workspace.aws_account_id}:role/${var.aws_role}"
  }
}

locals {
  env       = yamldecode(file("./one.yaml"))
  workspace = local.env["workspaces"][terraform.workspace]
}

# data "aws_caller_identity" "current" {}
# data "aws_region" "current" {}