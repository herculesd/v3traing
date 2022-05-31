module "ecr_repository" {
  for_each       = { for repository in local.workspace.ecr.repositories : repository.name => repository }
  source         = "git::https://github.com/DNXLabs/terraform-aws-ecr.git?ref=0.3.2"
  name           = each.value.name
  trust_accounts = try(local.workspace.ecr.trust_account_ids, [])
}
