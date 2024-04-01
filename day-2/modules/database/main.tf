resource "aws_db_instance" "three_tier_db" {
    identifier = var.db_identifier
    allocated_storage = var.db_allocated_storage
    instance_class = var.db_instance_class
    engine = "mysql"
    engine_version = var.db_engine_version
    db_name = var.db_name
    username = var.db_username
    password = var.db_password
    db_subnet_group_name = var.db_subnet_group_name
    skip_final_snapshot = var.db_skip_final_snapshot

    vpc_security_group_ids = [var.rds_sg]

    tags = {
        "Name"="three_tier_rds"
    }
}