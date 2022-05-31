resource "helm_release" "rancher_logging_crd" {
  count      = local.workspace.rancher_logging.enable ? 1 : 0
  name       = "rancher-logging-crd"
  repository = "https://charts.rancher.io"
  chart      = "rancher-logging-crd"
  version    = "3.9.000"
  namespace  = "cattle-logging-system"
  create_namespace = true
}

resource "helm_release" "rancher_logging" {
  depends_on = [helm_release.rancher_logging_crd]  
  count      = local.workspace.rancher_logging.enable ? 1 : 0
  name       = "rancher-logging"
  repository = "https://charts.rancher.io"
  chart      = "rancher-logging"
  version    = "3.9.000"
  namespace  = "cattle-logging-system"

  set {
    name = "tolerations[0].effect"
    value = "NoSchedule"
  }  

  set {
    name = "tolerations[0].operator"
    value = "Exists"
  }  

  set {
    name = "tolerations[1].effect"
    value = "NoExecute"
  }  

  set {
    name = "tolerations[1].operator"
    value = "Exists"
  }  

  set {
    name = "fluentbit.tolerations[0].effect"
    value = "NoSchedule"
  }  

  set {
    name = "fluentbit.tolerations[0].operator"
    value = "Exists"
  }  

  set {
    name = "fluentbit.tolerations[1].effect"
    value = "NoExecute"
  }  

  set {
    name = "fluentbit.tolerations[1].operator"
    value = "Exists"
  }  
}

resource "helm_release" "loki" {
  depends_on = [helm_release.rancher_logging_crd]
  count      = local.workspace.rancher_logging.enable ? 1 : 0
  name             = "loki"
  chart            = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  version          =  "2.6.0"
  namespace        = "cattle-logging-system"

  # DEPRECATED flag -store.max-look-back-period, use -querier.max-query-lookback instead
  # name = "config.chunk_store_config.max_look_back_period"
  # value = local.workspace.rancher_logging.max_look_back_period
  set {
    name = "config.limits_config.max_query_lookback"
    value = local.workspace.rancher_logging.max_query_lookback
  }

  set {
    name = "config.limits_config.max_entries_limit_per_query"
    value = 100000
  } 

  set {
    name = "config.limits_config.reject_old_samples"
    value = "true"
  }

  set {
    name = "config.limits_config.reject_old_samples_max_age"
    value = local.workspace.rancher_logging.reject_old_samples_max_age
  }

  set {
    name = "config.limits_config.retention_period"
    value = local.workspace.rancher_logging.retention_period
  }

  set {
    name = "config.table_manager.retention_deletes_enabled"
    value = "true"
  } 

  set {
    name = "config.table_manager.retention_period"
    value = local.workspace.rancher_logging.table_retention_period
  } 

  set {
    name = "config.server.grpc_server_max_recv_msg_size"
    value = 8388608
  } 

  set {
    name = "config.server.grpc_server_max_send_msg_size"
    value = 8388608
  } 

  set {
    name = "persistence.enabled"
    value = "true"
  } 

  set {
    name = "persistence.accessModes[0]"
    value = "ReadWriteOnce"
  } 

  set {
    name = "persistence.size"
    value = local.workspace.rancher_logging.storage
  } 

  set {
    name = "persistence.storageClassName"
    value = "gp2"
  }
}

resource "kubectl_manifest" "logging_output" {
  depends_on = [helm_release.loki] 
  count = local.workspace.rancher_logging.enable ?  length(local.workspace.rancher_logging.namespaces) : 0
  yaml_body = templatefile("${path.module}/manifests/output-logging.yaml", {
  namespace = local.workspace.rancher_logging.namespaces[count.index]})
}

resource "kubectl_manifest" "logging_flow" {
  depends_on = [helm_release.loki,kubectl_manifest.logging_output] 
  count = local.workspace.rancher_logging.enable ?  length(local.workspace.rancher_logging.namespaces) : 0
  yaml_body = templatefile("${path.module}/manifests/flow-logging.yaml", {
  namespace = local.workspace.rancher_logging.namespaces[count.index]})
}
