module "cluster_autoscaler" {
  source  = "DNXLabs/eks-cluster-autoscaler/aws"
  version = "0.1.2"
  enabled = local.workspace.cluster_autoscaler.enabled

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn
  aws_region                       = data.aws_region.current.name
  create_namespace                 = false
}


module "metrics_server" {
  source  = "DNXLabs/eks-metrics-server/aws"
  version = "0.1.2"
  enabled = local.workspace.metrics_server.enabled
}


module "node_termination_handler" {
  source  = "DNXLabs/eks-node-termination-handler/aws"
  version = "0.1.3"
  enabled = local.workspace.node_termination_handler.enabled
}

module "load_balancer_controller" {
  source  = "DNXLabs/eks-lb-controller/aws"
  version = "0.4.0"
  enabled = local.workspace.load_balancer_controller.enabled

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn
}

module "cloudwatch_metrics" {
  source  = "DNXLabs/eks-cloudwatch-metrics/aws"
  version = "0.1.1"
  enabled = local.workspace.cloudwatch_metrics.enabled

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn
  worker_iam_role_name             = data.aws_iam_role.workers.id
}

module "cloudwatch_logs" {
  source  = "DNXLabs/eks-cloudwatch-logs/aws"
  version = "0.1.3"
  enabled = local.workspace.cloudwatch_logs.enabled

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn
  worker_iam_role_name             = data.aws_iam_role.workers.id
  region                           = data.aws_region.current.name
  settings = {
    "cloudWatch.logRetentionDays" = local.workspace.cloudwatch_logs.retention
  }  
}

module "external_dns" {
  source  = "DNXLabs/eks-external-dns/aws"
  version = "0.1.4"
  enabled = local.workspace.external_dns.enabled

  cluster_name                     = data.aws_eks_cluster.cluster.id
  cluster_identity_oidc_issuer     = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_identity_oidc_issuer_arn = local.workspace.oidc_provider_arn

  settings = {
    "policy"        = "sync" # Modify how DNS records are sychronized between sources and providers.
    "provider"      = "aws"
    "aws.zoneType"  = "public"
    "txtOwnerId"    = local.workspace.external_dns.cluster_id
    "domainFilters" = local.workspace.external_dns.domains
  }
}