resource "aws_iam_user" "read_only_account" {
  name = "read_only_account"
  force_destroy = true
  tags {
    tag-key="tag-value"
  }
}

resource "aws_iam_access_key" "read_only_user_access_key" {
  user = "${aws_iam_user.read_only_account.id}"
}

data "aws_iam_policy_document" "read_only_account" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:DescribeInstances"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "read_only_policy" {
  policy = "${data.aws_iam_policy_document.read_only_account.json}"
  name="ec2-read_only"
}

resource "aws_iam_policy_attachment" "read_only_attachment" {
  name = "read_only_policy_attachment"
  policy_arn = "${aws_iam_policy.read_only_policy.arn}"
  users = ["${aws_iam_user.read_only_account.name}"]
}

