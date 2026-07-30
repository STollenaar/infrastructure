resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "cmstate.spicedelver.me" = "opt-out"
    }
  }
}

resource "helm_release" "cert_manager" {
  name        = "cert-manager"
  chart       = "cert-manager"
  version     = "v1.21.1"
  repository  = "https://charts.jetstack.io"
  namespace   = kubernetes_namespace.cert_manager.id
  wait        = false
  max_history = 5
  values = [templatefile("${path.module}/conf/cert-manager-values.yaml", {
  })]

}


resource "kubernetes_manifest" "vault_cluster_issuer" {
  depends_on = [helm_release.cert_manager]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "vault-issuer"
    }
    spec = {
      vault = {
        path   = "pki_int/sign/cert-manager"
        server = "http://vault.vault.svc.cluster.local:8200"
        auth = {
          kubernetes = {
            role      = "cert-manager"
            mountPath = "/v1/auth/kubernetes"
            serviceAccountRef = {
              name = "cert-manager"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_secret_v1" "route53_credentials_secret" {
  metadata {
    name      = "route53-credentials-secret"
    namespace = kubernetes_namespace.cert_manager.id
  }
  data = {
    "access-key-id"     = data.aws_ssm_parameter.route53_user_access_key.value
    "secret-access-key" = data.aws_ssm_parameter.route53_user_secret_access_key.value
  }
}

resource "kubernetes_manifest" "letsencrypt_cluster_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-prod"
    }
    "spec" = {
      "acme" = {
        "email"  = "stephen@tollenaar.com"
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          "name" = "letsencrypt-prod"
        }
        "solvers" = [{
          "dns01" = {
            "route53" = {
              "region" = "ca-central-1"
              "accessKeyIDSecretRef" = {
                "name" = kubernetes_secret_v1.route53_credentials_secret.metadata.0.name
                "key"  = "access-key-id"
              }
              "secretAccessKeySecretRef" = {
                "name" = kubernetes_secret_v1.route53_credentials_secret.metadata.0.name
                "key"  = "secret-access-key"
              }
            }
          }
        }]
      }
    }
  }
}

 resource "kubernetes_role" "cert_manager_tokenrequest" {
    metadata {
      name      = "cert-manager-tokenrequest"
      namespace = kubernetes_namespace.cert_manager.id
    }
    rule {
      api_groups     = [""]
      resources      = ["serviceaccounts/token"]
      resource_names = ["cert-manager"]
      verbs          = ["create"]
    }
  }

  resource "kubernetes_role_binding" "cert_manager_tokenrequest" {
    metadata {
      name      = "cert-manager-tokenrequest"
      namespace = kubernetes_namespace.cert_manager.id
    }
    role_ref {
      api_group = "rbac.authorization.k8s.io"
      kind      = "Role"
      name      = kubernetes_role.cert_manager_tokenrequest.metadata.0.name
    }
    subject {
      kind      = "ServiceAccount"
      name      = "cert-manager"
      namespace = kubernetes_namespace.cert_manager.id
    }
  }