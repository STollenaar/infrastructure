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

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket  = "stollenaar-terraform-states"
    encrypt = true
    key     = "infrastructure/aws/iam/terraform.tfstate"
    region  = "ca-central-1"
  }
}
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "stollenaar-terraform-states"
    encrypt = true
    key     = "infrastructure/aws/vpc/terraform.tfstate"
    region  = "ca-central-1"
  }
}
