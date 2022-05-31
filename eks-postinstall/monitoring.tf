resource "helm_release" "rancher_monitoring_crd" {
  count      = local.workspace.rancher_monitoring.enable ? 1 : 0
  name       = "rancher-monitoring-crd"
  repository = "https://charts.rancher.io"
  chart      = "rancher-monitoring-crd"
  version    = "9.4.203"
  namespace  = "cattle-monitoring-system"
  create_namespace = true
}

resource "helm_release" "rancher_monitoring" {
  depends_on = [helm_release.rancher_monitoring_crd]
  count      = local.workspace.rancher_monitoring.enable ? 1 : 0
  name       = "rancher-monitoring"
  repository = "https://charts.rancher.io"
  chart      = "rancher-monitoring"
  version    = "9.4.203"
  namespace  = "cattle-monitoring-system"

  set {
    name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]"
    value = "ReadWriteOnce"
  }

  set {
    name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = local.workspace.rancher_monitoring.storage_prometheus
  }

  set {
    name = "prometheus.prometheusSpec.retentionSize"
    value = "${local.workspace.rancher_monitoring.storage_prometheus}B"
  }

  set {
    name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.volumeMode"
    value = "Filesystem"
  }

  set {
    name = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "gp2"
  }  

  set {
    name = "grafana.persistence.enabled"
    value = "true"
  }

  set {
    name = "grafana.persistence.accessModes[0]"
    value = "ReadWriteOnce"
  }

  set {
    name = "grafana.persistence.storageClassName"
    value = "gp2"
  }

  set {
    name = "grafana.persistence.size"
    value = local.workspace.rancher_monitoring.storage_grafana
  }  

  set {
    name = "grafana.persistence.type"
    value = "statefulset"
  }

  set {
    name = "prometheus.prometheusSpec.resources.limits.cpu"
    value = local.workspace.rancher_monitoring.cpu_limit_prometheus
  }

  set {
    name = "prometheus.prometheusSpec.resources.limits.memory"
    value = local.workspace.rancher_monitoring.memory_limit_prometheus
  }   

  set {
    name = "prometheus.prometheusSpec.resources.requests.cpu"
    value = local.workspace.rancher_monitoring.cpu_requests_prometheus
  }

  set {
    name = "prometheus.prometheusSpec.resources.requests.memory"
    value = local.workspace.rancher_monitoring.memory_requests_prometheus
  }   

  set {
    name = "prometheus.prometheusSpec.evaluationInterval"
    value = "1m"
  }

  set {
    name = "prometheus.prometheusSpec.scrapeInterval"
    value = "1m"
  }

  set {
    name = "prometheus.prometheusSpec.retention"
    value = local.workspace.rancher_monitoring.retention
  }
}

resource "kubectl_manifest" "grafana" {
  count      = local.workspace.grafana_ingress.enable ? 1 : 0
  depends_on = [helm_release.rancher_monitoring]
  yaml_body  = templatefile("${path.module}/manifests/ingress-grafana.yaml", {
    hostname = local.workspace.grafana_ingress.name,
    domain = local.workspace.domain,
    group_name = "${local.workspace.grafana_ingress.load_balance_type == "internal" ? "internal" : "internet-facing"}",
    schema = "${local.workspace.grafana_ingress.load_balance_type == "internal" ? "internal" : "internet-facing"}"})
}
