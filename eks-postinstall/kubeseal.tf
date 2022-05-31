resource "helm_release" "sealed-secrets" {
  count      = local.workspace.kubeseal.enable ? 1 : 0
  name             = "sealed-secrets"
  chart            = "sealed-secrets"
  repository       = "https://bitnami-labs.github.io/sealed-secrets"
  namespace        = "kube-system"
  version          =  local.workspace.kubeseal.version

 set {
      name = "dashboards.create"
      value = "true"
  }    
}
