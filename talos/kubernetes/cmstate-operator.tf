resource "kubernetes_namespace" "cmstate_operator" {
  metadata {
    name = "cmstate-operator"
    labels = {
      "cmstate.spicedelver.me" = "opt-out"
    }
  }
}

resource "kubernetes_labels" "kube_system_label" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "kube-system"
  }
  labels = {
    "cmstate.spicedelver.me" = "opt-out"
  }
}

resource "helm_release" "cmstate_operator" {
  name       = "cmstate-operator"
  version    = "0.3.0"
  namespace  = kubernetes_namespace.cmstate_operator.metadata.0.name
  repository = "https://stollenaar.github.io/cmstate-injector-operator"
  chart      = "cmstate-operator"

  values = [templatefile("${path.module}/conf/cmstate-operator-values.yaml", {
    ca_secret   = "${kubernetes_namespace.cmstate_operator.metadata.0.name}/${kubernetes_secret.vault_cert_issuer.metadata.0.name}"
    cert_secret = kubernetes_secret.vault_cert_issuer.metadata.0.name
  })]
}

resource "kubernetes_service_account" "vault_issuer" {
  metadata {
    name      = "vault-issuer"
    namespace = kubernetes_namespace.cmstate_operator.metadata.0.name
  }
}

resource "kubernetes_role" "vault_issuer_role" {
  metadata {
    name      = "vault-issuer"
    namespace = kubernetes_namespace.cmstate_operator.metadata.0.name
  }

  rule {
    api_groups     = [""]
    resources      = ["serviceaccounts/token"]
    resource_names = ["vault-issuer"]
    verbs          = ["create"]
  }
}

resource "kubernetes_role_binding" "vault_issuer_role_binding" {
  metadata {
    name      = "vault-issuer"
    namespace = kubernetes_namespace.cmstate_operator.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "cert-manager"
    namespace = kubernetes_namespace.cert_manager.metadata.0.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.vault_issuer_role.metadata.0.name
  }
}


resource "kubernetes_secret" "vault_cert_issuer" {
  metadata {
    name      = "vault-cert-issuer-role"
    namespace = kubernetes_namespace.cmstate_operator.metadata.0.name
    annotations = {
      "cert-manager.io/allow-direct-injection" = "true"
    }
  }
  lifecycle {
    ignore_changes = [metadata.0.annotations, metadata.0.labels]
  }
}

resource "kubernetes_manifest" "cert_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "cmstates-webhook-cert"
      namespace = kubernetes_namespace.cmstate_operator.metadata.0.name
    }
    spec = {
      secretName = "cmstates-webhook-cert"
      issuerRef = {
        kind = "ClusterIssuer"
        name = kubernetes_manifest.vault_cluster_issuer.manifest.metadata.name
      }
      dnsNames = [
        "cmstate-operator-service.${kubernetes_namespace.cmstate_operator.metadata.0.name}.svc.cluster.local"
      ]
      commonName = "cmstate-operator-service.${kubernetes_namespace.cmstate_operator.metadata.0.name}.svc.cluster.local"
      privateKey = {
        algorithm = "RSA"
        encoding  = "PKCS1"
        size      = 4096
      }
    }
  }
}

resource "kubernetes_manifest" "cm_vault_template" {
  manifest = {
    apiVersion = "cache.spicedelver.me/v1alpha1"
    kind       = "CMTemplate"
    metadata = {
      name = "vault-aws-agent"
    }
    spec = {
      template = {
        targetAnnotation = "vault.hashicorp.com/agent-configmap"
        annotationreplace = {
          "vault.hashicorp.com/aws-role" = "{aws_role_name}"
          "vault.hashicorp.com/role"     = "{internal_role_name}"
        }
        cmtemplate = {
          "config.hcl" = templatefile("${path.module}/conf/vault-agent.hcl.tpl", {
            exit_after_auth = false
          })
          "config-init.hcl" = templatefile("${path.module}/conf/vault-agent.hcl.tpl", {
            exit_after_auth = true
          })
        }
      }
    }
  }
}
