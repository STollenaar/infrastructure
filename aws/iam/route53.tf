data "aws_iam_policy_document" "route53_manager_policy_document" {
  statement {
    sid    = "Route53Manager"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = [
      "*" #TODO: Add specific route53
    ]
  }
  statement {
    sid    = "Route53Change"
    effect = "Allow"
    actions = [
      "route53:GetChange"
    ]
    resources = [
      "arn:aws:route53:::change/*"
    ]
  }
  statement {
    sid    = "Route53Reader"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListHostedZonesByName"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_user" "route53_user" {
  name = "route53-manager"
}

resource "aws_iam_access_key" "route53_user_key" {
  user = aws_iam_user.route53_user.name
}

resource "aws_iam_user_policy" "route53_user_policy" {
  name   = "route53"
  user   = aws_iam_user.route53_user.name
  policy = data.aws_iam_policy_document.route53_manager_policy_document.json
}
