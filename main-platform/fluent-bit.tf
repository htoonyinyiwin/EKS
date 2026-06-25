resource "helm_release" "fluent_bit" {
  name             = "fluent-bit"
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  namespace        = "monitoring"
  create_namespace = false
  wait             = false # pods depend on grafana-loki-secret which ESO syncs async; don't block tf apply

  values = [<<-YAML
    envFrom:
      - secretRef:
          name: grafana-loki-secret

    config:
      inputs: |
        [INPUT]
            Name              tail
            Path              /var/log/containers/*.log
            multiline.parser  docker, cri
            Tag               kube.*
            Mem_Buf_Limit     50MB
            Skip_Long_Lines   On

      filters: |
        [FILTER]
            Name                kubernetes
            Match               kube.*
            Kube_URL            https://kubernetes.default.svc:443
            Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
            Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token
            Kube_Tag_Prefix     kube.var.log.containers.
            Merge_Log           On
            Keep_Log            Off
            K8S-Logging.Parser  On
            K8S-Logging.Exclude On

      outputs: |
        [OUTPUT]
            Name              loki
            Match             kube.*
            host              logs-prod-020.grafana.net
            port              443
            tls               On
            tls.verify        On
            http_user         $${LOKI_USERNAME}
            http_passwd       $${LOKI_PASSWORD}
            labels            job=fluent-bit,cluster=eks-eks-${var.env},env=${var.env}
            label_keys        $kubernetes['namespace_name'],$kubernetes['pod_name'],$kubernetes['container_name']
            line_format       json
    YAML
  ]

  depends_on = [kubectl_manifest.external_secret_grafana_loki]
}
