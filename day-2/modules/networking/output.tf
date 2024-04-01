output "vpc_id" {
  value = aws_vpc.three_tier_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.three_tier_db_subnetgroup.*.name
}

output "rds_db_subnet_group_id" {
  value = aws_db_subnet_group.three_tier_db_subnetgroup.*.id
}

output "rds_sg" {
  value = aws_security_group.three_tier_db_sg.id
}

output "frontend_app_sg" {
  value = aws_security_group.three_tier_frontend_sg.id
}

output "backend_app_sg" {
  value = aws_security_group.three_tier_backend_sg.id
}

output "lb_sg" {
  value = aws_security_group.three_tier_lb_sg.id
}

output "public_subnets" {
  value = aws_subnet.three_tier_public_subnets.*.id
}

output "private_subnets" {
  value = aws_subnet.three_tier_private_subnets.*.id
}

output "bastion_sg" {
  value = aws_security_group.three_tier_bastion_sg.id
}
