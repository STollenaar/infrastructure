resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "PKI management"

  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 315360000
}

resource "vault_pki_secret_backend_root_cert" "root" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "kubernetes-root-ca.svc.cluster.local"
  ttl         = 315360000
  issuer_name = "root"

  lifecycle {
    ignore_changes = [common_name, ttl]
  }
}

resource "vault_pki_secret_backend_config_urls" "config-urls" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = ["http://vault.vault.svc.cluster.local:8200/v1/pki/ca"]
  crl_distribution_points = ["http://vault.vault.svc.cluster.local:8200/v1/pki/crl"]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate_csr" {
  backend     = vault_mount.pki_int.path
  type        = "internal"
  common_name = "vault-intermediate-ca.svc.cluster.local"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "sign_intermediate" {
  backend     = vault_mount.pki.path
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate_csr.csr
  common_name = "vault-intermediate-ca.svc.cluster.local"
  format      = "pem_bundle"
  ttl         = "43800h"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "set_intermediate" {
  backend     = vault_mount.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.sign_intermediate.certificate
}


resource "vault_mount" "pki_int" {
  path        = "pki_int"
  type        = "pki"
  description = "This is an example intermediate PKI mount"

  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 157680000
}

resource "vault_pki_secret_backend_role" "cert_manager_role" {
  backend          = vault_mount.pki_int.path
  name             = "cert-manager"
  ttl              = 86400   # 1 day certificates
  max_ttl          = "2160h" # 90 days
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["spicedelver.me", "svc.cluster.local", "svc"]
  allow_subdomains = true
  allow_any_name   = false
}

data "vault_policy_document" "cert_manager_policy" {
  rule {
    path         = "pki_int/issue/cert-manager"
    capabilities = ["create", "update"]
    description  = "Allow cert-manager to issue certificates"
  }
  rule {
    path         = "pki_int/sign/cert-manager"
    capabilities = ["create", "update"]
    description  = "Allow cert-manager to sign intermediate certificates"
  }
  rule {
    path         = "pki_int/certs/*"
    capabilities = ["read"]
    description  = "Allow cert-manager to read issued certificates"
  }
}

resource "vault_policy" "cert_manager" {
  name   = "cert-manager"
  policy = data.vault_policy_document.cert_manager_policy.hcl
}

resource "vault_kubernetes_auth_backend_role" "cert_manager_k8s_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "cert-manager"
  bound_service_account_names      = ["cert-manager"]
  bound_service_account_namespaces = ["cert-manager"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.cert_manager.name]
}
