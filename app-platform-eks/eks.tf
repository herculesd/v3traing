data "aws_eks_cluster" "cluster" {
  count = local.workspace.eks.enabled ? 1 : 0
  name  = module.eks_cluster[0].cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = local.workspace.eks.enabled ? 1 : 0
  name  = module.eks_cluster[0].cluster_id
}

# In case of not creating the cluster, this will be an incompletely configured, unused provider, which poses no problem.
provider "kubernetes" {
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, [""]), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, [""]), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
}

resource "aws_kms_key" "eks" {
  count       = local.workspace.eks.enabled ? 1 : 0
  description = "EKS Secret Encryption Key"
}

module "eks_cluster" {
  count  = local.workspace.eks.enabled ? 1 : 0
  source = "terraform-aws-modules/eks/aws"

  create_eks                      = true
  version                         = "17.1.0"
  cluster_name                    = local.workspace.eks.name
  cluster_version                 = local.workspace.eks.version
  write_kubeconfig                = false
  enable_irsa                     = true
  cluster_enabled_log_types       = ["controllerManager"]
  cluster_iam_role_name           = "eks-cluster-${local.workspace.eks.name}-${data.aws_region.current.name}"
  workers_role_name               = "eks-workers-${local.workspace.eks.name}-${data.aws_region.current.name}"
  fargate_pod_execution_role_name = "eks-fargate-${local.workspace.eks.name}-${data.aws_region.current.name}"

  cluster_endpoint_private_access = true

  subnets = data.aws_subnets.private.ids 
  vpc_id  = data.aws_vpc.selected.id 

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks[0].arn
      resources        = ["secrets"]
    }
  ]

  node_groups = local.node_groups_config[local.workspace.account_name]
  # node_groups = local.workspace.eks.name == "prod-apps" ? local.prod_node_groups : local.nonprod_node_groups
  # node_groups = local.node_groups_config

  tags = {
    "k8s.io/cluster-autoscaler/${local.workspace.eks.name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"                     = "TRUE"
  }

  manage_aws_auth = true

  map_roles    = local.workspace.eks.map_roles
  map_users    = local.workspace.eks.map_users
  map_accounts = local.workspace.eks.map_accounts

  # Create security group rules to allow communication between pods on workers and pods in managed node groups.
  # Set this to true if you have AWS-Managed node groups and Self-Managed worker groups.
  # See https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1089

  worker_create_cluster_primary_security_group_rules = false
}

# output "eks_cluster_oidc_provider_arn" {
#   value = { for cluster_name, output in module.eks_cluster : cluster_name => output.oidc_provider_arn }
# }
