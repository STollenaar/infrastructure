exit_after_auth = ${exit_after_auth}
pid_file        = "/home/vault/.pid"

auto_auth = {
  method "aws" {
    mount_path = "auth/aws"
    config = {
      type = "iam"
      role = "{internal_role_name}"
    }
  }
  sink "file" {
    config = {
      path = "/vault/secrets/.token"
    }
  }
}

vault = {
  address = "https://vault.vault.svc.cluster.local:8200"
}
