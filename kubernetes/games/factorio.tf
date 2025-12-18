resource "kubernetes_namespace_v1" "factorio" {
  metadata {
    name = "factorio"
  }
}

resource "helm_release" "factorio" {
  name      = "factorio"
  namespace = kubernetes_namespace_v1.factorio.id

  repository = "https://sqljames.github.io/factorio-server-charts"
  chart      = "factorio-server-charts"
  version    = "2.5.2"

  values = [templatefile("${path.module}/conf/factorio-values.yaml", {
    server_password = random_password.server_password.result
    account_secret  = kubernetes_secret_v1.factorio_secret.metadata.0.name
    username        = data.aws_ssm_parameter.factorio_username.value
    account_token   = data.aws_ssm_parameter.factorio_token.value
  })]
}

resource "random_password" "server_password" {
  length = 10
}

resource "aws_ssm_parameter" "factorio_server_password" {
  name  = "/factorio/server_password"
  type  = "SecureString"
  value = random_password.server_password.result
}

resource "kubernetes_secret_v1" "factorio_secret" {
  metadata {
    name      = "factorio"
    namespace = kubernetes_namespace_v1.factorio.id
  }
  data = {
    username = data.aws_ssm_parameter.factorio_username.value
    token    = data.aws_ssm_parameter.factorio_token.value
  }
}
