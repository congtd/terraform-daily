provider "aws" {
  region = local.location
}

locals {
  instance_type = "t2.micro"
  location = "ap-northeast-1"
  env = "dev"
  vpc_cird = "10.123.0.0/16"
}

module "networking" {
  source = "../modules/networking"
  vpc_cird = local.vpc_cird
  access_ip = var.access_ip
  private_subnet_count = 2
  public_subnet_count = 2
  db_subnet_group = true
}

module "compute" {
  source = "../modules/compute"
  instance_type = local.instance_type
  ssh_key = "testkey"
  lb_tg_name = "three_tier_lb_tg"
  key_name = "three_tier_key"
  public_subnets = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  frontend_app_sg = module.networking.frontend_app_sg
  backend_app_sg = module.networking.backend_app_sg
  bastion_sg = module.networking.bastion_sg
}

module "database" {
  source = "../modules/database"
  db_allocated_storage = 10
  db_instance_class = "db.t2.micro"
  db_engine_version = "8.0"
  db_name = "threetier-db"
  db_username ="kong"
  db_password ="password"
  db_subnet_group_name = module.networking.rds_db_subnet_group_id[0]
  db_identifier = "ee-instance-demo"
  db_skip_final_snapshot = true
  rds_sg = module.networking.rds_sg
}

module "load_balancing" {
  source = "../modules/loadbalancing"
  lb_sg = module.networking.lb_sg
  public_subnets = module.networking.public_subnets
  app_sg = module.compute.app_asg
  port = 80
  protocol = "HTTP"
  vpc_id = module.networking.vpc_id
}