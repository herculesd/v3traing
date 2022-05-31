resource "helm_release" "rancher_kiali_server_crd" {
  count      = local.workspace.istio.enable ? 1 : 0
  name       = "rancher-kiali-server-crd"
  repository = "https://charts.rancher.io"
  chart      = "rancher-kiali-server-crd"
  version    = "1.32.100"
  namespace  = "istio-system"
  create_namespace = true
}

resource "helm_release" "rancher_istio" {
  depends_on = [helm_release.rancher_kiali_server_crd]  
  count      = local.workspace.istio.enable ? 1 : 0
  name       = "rancher-istio"
  repository = "https://charts.rancher.io"
  chart      = "rancher-istio"
  version    = "1.9.600"
  namespace  = "istio-system"
}
