data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${local.workspace.account_name}-VPC"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Scheme"
    values = ["private"]
  }
}
