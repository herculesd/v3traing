module "argocd" {
  source  = "DNXLabs/eks-argocd/aws"
  version = "0.3.3"

  enabled = local.workspace.argocd.enable

helm_services = [
    {
      name          = "argo-cd"
      release_name  = "argo-cd"
      chart_version = local.workspace.argocd.argocd_version
      settings      = {
        "controller":{"metrics":{"enabled": "false", "serviceMonitor":{"enabled": "false"}}}
        "server":{"extraArgs": ["--insecure"], "config":{"url": "https://${local.workspace.argocd.hostname}.${local.workspace.domain}"}}
      }
    },
    {
      name          = "argo-rollouts"
      release_name  = "argo-rollouts"
      chart_version = local.workspace.argocd.rollout_version
      settings      = {
        "controller":{"metrics":{"enabled": "false", "serviceMonitor":{"enabled": "false"}}}
      }
    },
    {
      name          = "argocd-notifications"
      release_name  = "argocd-notifications"
      chart_version = local.workspace.argocd.notification_version
      settings      = {}
    } 
  ]
}

resource "kubectl_manifest" "argocd_ingress" {
  count      = local.workspace.argocd.enable ? 1 : 0
  depends_on = [module.argocd,module.load_balancer_controller]
  yaml_body  = templatefile("${path.module}/manifests/argocd-ingress.yaml", 
   {
       hostname = local.workspace.argocd.hostname,
       domain = local.workspace.domain,
       group_name = "${local.workspace.argocd.load_balance_type == "internal" ? "internal" : "internet-facing"}",
       schema = "${local.workspace.argocd.load_balance_type == "internal" ? "internal" : "internet-facing"}"})
}
