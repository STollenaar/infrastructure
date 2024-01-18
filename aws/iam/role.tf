resource "aws_iam_role" "spices_role" {
  name               = "SpicesRole"
  description        = "Role for the spices EC2 instance"
  assume_role_policy = data.aws_iam_policy_document.assume_policy_document.json
}

resource "aws_iam_instance_profile" "test_profile" {
  name = aws_iam_role.spices_role.name
  role = aws_iam_role.spices_role.name
}

resource "aws_iam_role_policy" "spices_role_policy" {
  role   = aws_iam_role.spices_role.id
  name   = "ECRAccess"
  policy = data.aws_iam_policy_document.spices_role_policy_document.json
}

resource "aws_iam_role_policy_attachment" "spices_role_core_attachment" {
  role       = aws_iam_role.spices_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "spices_role_cloudwatch_attachment" {
  role       = aws_iam_role.spices_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "spices_role_patch_attachment" {
  role       = aws_iam_role.spices_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}
