output "permission_sets_arn" {
   value = { for k,ps  in  aws_ssoadmin_permission_set.this: k => ps.arn }
}
