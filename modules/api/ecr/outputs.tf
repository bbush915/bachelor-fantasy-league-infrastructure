output "ecr_admin_role_arn" {
  value = "${aws_iam_role.api_ecr_admin_role.arn}"
}
