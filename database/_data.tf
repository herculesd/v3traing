data "aws_security_group" "eks_sg" {
  count  = local.workspace.eks.enabled ? 1 : 0
  tags   = {
    Name = length(try(local.workspace.eks.name, "")) > 0 ? "${local.workspace.eks.name}-eks_worker_sg" : null
  }
}

data "aws_security_group" "vpn_sg" {
  filter {
    name   = "tag:Name"
    values = ["ecs-${local.workspace.account_name}-vpn-nodes"]
  }
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${local.workspace.account_name}-VPC"]
  }
}

data "aws_db_subnet_group" "default" {
  name = "${local.workspace.account_name}-dbsubnet"
}
