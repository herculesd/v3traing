module "network" {
  count  = local.workspace.network.enabled ? 1 : 0
  source = "git::https://github.com/DNXLabs/terraform-aws-network.git?ref=1.5.0"

  newbits             = try(local.workspace.network.vpc_newbits, "")
  vpc_cidr            = try(local.workspace.network.vpc_cidr, "")
  name                = try(local.workspace.network.name, "")
  multi_nat           = try(local.workspace.network.multi_nat, "")
  transit_subnet      = try(local.workspace.network.transit_subnet, "")
  max_az              = 3
  kubernetes_clusters = [try(local.workspace.eks.name, "")]
  vpc_endpoints       = ["ecr.dkr", "ssm", "ssmmessages", "logs", "ecr.api", "ecs"]
}

output "network_private_subnet_cidrs" {
  value = try(module.network[0].private_subnet_cidrs[0], [])
}

output "network_public_subnet_cidrs" {
  value = try(module.network[0].public_subnet_cidrs[0], [])
}

output "network_secure_subnet_cidrs" {
  value = try(module.network[0].secure_subnet_cidrs[0], [])
}

output "network_private_subnet_ids" {
  value = try(module.network[0].private_subnet_ids[0], [])
}

output "network_public_subnet_ids" {
  value = try(module.network[0].public_subnet_ids[0], [])
}

output "network_secure_subnet_ids" {
  value = try(module.network[0].secure_subnet_ids[0], [])
}

output "network_vpc_id" {
  value = try(module.network[0].vpc_id, [])
}
