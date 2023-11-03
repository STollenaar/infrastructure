resource "kubernetes_manifest" "allow_aws_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "aws-services"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "302283948774.dkr.ecr.ca-central-1.amazonaws.com",
        "api.ecr.ca-central-1.amazonaws.com",
        "codebuild.ca-central-1.amazonaws.com",
        "cognito-idp.ca-central-1.amazonaws.com",
        "ec2.amazonaws.com",
        "eks.amazonaws.com",
        "eks.ca-central-1.amazonaws.com",
        "email-smtp.ca-central-1.amazonaws.com",
        "kms.amazonaws.com",
        "lambda.ca-central-1.amazonaws.com",
        "logs.ca-central-1.amazonaws.com",
        "oidc.eks.ca-central-1.amazonaws.com",
        "ssm.ca-central-1.amazonaws.com",
        "s3.ca-central-1.amazonaws.com",
        "sts.amazonaws.com",
        "sts.ca-central-1.amazonaws.com",
        "sts.us-east-1.amazonaws.com"
      ]

      ports = [
        {
          number   = 443
          name     = "https"
          protocol = "TLS"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "allow_aws_ses_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "aws-ses-services"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "ses.amazonaws.com",
        "email-smtp.ca-central-1.amazonaws.com",
      ]

      ports = [
        {
          number   = 465
          name     = "https"
          protocol = "TLS"
        },
        {
          number   = 587
          name     = "smtp"
          protocol = "TLS"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "allow_pagerduty" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "pagerduty-services"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "events.pagerduty.com",
      ]

      ports = [
        {
          number   = 443
          name     = "https"
          protocol = "TLS"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "allow_auth_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "auth-services"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "accounts.google.com",
        "www.googleapis.com",
        "fcm.googleapis.com"
      ]
      ports = [
        {
          number   = 443
          name     = "https"
          protocol = "TLS"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "allow_sentry_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "sentry-services"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "sentry.io",
        "o374975.ingest.sentry.io"
      ]
      ports = [
        {
          number   = 443
          name     = "https"
          protocol = "TLS"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "DNS"
    }
  }
}

resource "kubernetes_manifest" "allow_wildcard_aws_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "aws-wildcard-services"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "*.s3.ca-central-1.amazonaws.com",  // Maybe find a way to make sure this is an owned S3 Bucket
      ]
      ports = [
        {
          number   = 443
          name     = "https"
          protocol = "TLS"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "NONE"
    }
  }
}

resource "kubernetes_manifest" "allow_redis_wildcard_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "redis-wildcard-services"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "*.session-store.zicyvv.clustercfg.cac1.cache.amazonaws.com"
      ]
      ports = [
        {
          number   = 6379
          name     = "redis"
          protocol = "redis"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "NONE"
    }
  }
}

resource "kubernetes_manifest" "allow_ec2_metadata_services" {

  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "ServiceEntry"
    metadata = {
      name      = "ec2-metadata-services"
      namespace = var.istio_namespace
    }
    spec = {
      hosts = [
        "aws.metadata.internal"
      ]
      addresses = [
        "169.254.169.254"
      ]
      endpoints = [
        {
          address = "169.254.169.254"
        }
      ]
      ports = [
        {
          number   = 80
          name     = "http"
          protocol = "tcp"
        },
        {
          number   = 443
          name     = "https"
          protocol = "tcp"
        }
      ]
      location   = "MESH_EXTERNAL"
      resolution = "STATIC"
    }
  }
}
