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
  common_name = "cmstate-operator-service.cmstate-operator.svc"
  ttl         = 315360000
  issuer_name = "root"
}

resource "vault_pki_secret_backend_config_urls" "config-urls" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = ["http://localhost:8200/v1/pki/ca"]
  crl_distribution_points = ["http://localhost:8200/v1/pki/crl"]
}

resource "vault_mount" "pki_int" {
   path        = "pki_int"
   type        = "pki"
   description = "This is an example intermediate PKI mount"

   default_lease_ttl_seconds = 86400
   max_lease_ttl_seconds     = 157680000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "csr_request" {
   backend     = vault_mount.pki_int.path
   type        = "internal"
   common_name = "cmstate-operator-service.cmstate-operator.svc Intermediate Authority"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
   backend     = vault_mount.pki.path
   common_name = "cmstate-operator-service.cmstate-operator.svc"
   csr         = vault_pki_secret_backend_intermediate_cert_request.csr_request.csr
   format      = "pem_bundle"
   ttl         = 15480000
   issuer_ref  = vault_pki_secret_backend_root_cert.root.issuer_id
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
   backend     = vault_mount.pki_int.path
   certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki_int.path
  name             = "mutatingwebhook"
  ttl              = 86400
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["cmstate-operator-service.cmstate-operator.svc"]
  allow_subdomains = true
  allow_any_name   = true
}

data "vault_policy_document" "root_policy" {
  rule {
    path         = "pki*"
    capabilities = ["read", "list"]
    description  = "allow to read all pki"
  }
  rule {
    path         = "pki_int/roles/mutatingwebhook"
    capabilities = ["create", "update"]
    description  = "allow to manage the mutatingwebhook role"
  }
  rule {
    path         = "pki_int/sign/mutatingwebhook"
    capabilities = ["create", "update"]
    description  = "allow to sign the mutatingwebhook role"
  }
  rule {
    path         = "pki_int/issue/mutatingwebhook"
    capabilities = ["create"]
    description  = "allow to create the mutatingwebhook pki"
  }
}

resource "vault_policy" "root_policy" {
  name   = "pki"
  policy = data.vault_policy_document.root_policy.hcl
}

resource "vault_kubernetes_secret_backend_role" "vault_issuer" {
  backend                       = vault_kubernetes_secret_backend.kubernetes.path
  name                          = "vault-issuer"
  allowed_kubernetes_namespaces = ["cmstate-operator"] #TODO: Change to non critical namespaces

  kubernetes_role_type = "Role"
  service_account_name = "vault-issuer"
}

resource "vault_kubernetes_auth_backend_role" "mutating_issuer" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = vault_kubernetes_secret_backend_role.vault_issuer.name
  bound_service_account_names      = ["vault-issuer"]
  bound_service_account_namespaces = ["cmstate-operator"]
  audience                         = "vault://cmstate-operator/vault-issuer"
  token_ttl                        = 3600
  token_policies                   = [vault_policy.root_policy.name]
}
