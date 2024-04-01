output "load_balancing_endpoint" {
  value = module.load_balancing.lb_endpoint
}

output "database_endpoint" {
  value = module.database.db_endpoint
}

# output "config" {
#   value = {
#     bucket         = aws_s3_bucket.s3_bucket.bucket
#     role_arn       = aws_iam_role.iam_role.arn
#   }
# }