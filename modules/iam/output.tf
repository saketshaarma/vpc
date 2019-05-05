output "aws_read_only_access_key" {
  value = "${aws_iam_access_key.read_only_user_access_key.id}"
}
