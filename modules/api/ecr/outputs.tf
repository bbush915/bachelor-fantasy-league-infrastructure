output "ecr_admin_role_arn" {
  value = "${aws_iam_role.ecr_admin_role.arn}"
}
