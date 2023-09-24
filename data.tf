
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_iam_policy_document" "assume_policy_document" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ec2.amazonaws.com", "ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "spices_role_policy_document" {
  statement {
    sid    = "ECRReadAccess"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:ListImages"
    ]
    resources = [
      "arn:aws:ecr:*:405934267152:repository/*"
    ]
  }
  statement {
    sid    = "ECRDescribingAccess"
    effect = "Allow"
    actions = [
      "ecr:DescribeRegistry",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "S3Encryption"
    effect = "Allow"
    actions = [
      "s3:GetEncryptionConfiguration"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "KMSAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GetPublicKey",
      "kms:ListKeys"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "SSMAccess"
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = ["*"]
  }
  statement {
    sid    = "ECSRegistration"
    effect = "Allow"
    actions = [
      "ecs:RegisterContainerInstance",
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:SubmitAttachmentStateChange",
      "ecs:SubmitContainerStateChange",
      "ecs:SubmitTaskStateChange"
    ]
    resources = ["*"]
  }
}

data "awsprofiler_list" "list_profiles" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-arm64-ebs"]
  }
}

# Render a multi-part cloud-init config making use of the part
# above, and other source files
data "template_cloudinit_config" "config" {
  base64_encode = true

  part {
    content_type = "text/cloud-boothook"
    content      = file("${path.module}/conf/boothook.sh")
  }
  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/conf/userdata.sh", {
      cluster_name = aws_ecs_cluster.discord_bots_cluster.name
    })
  }
}
