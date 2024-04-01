#launch template for bastion host

data "aws_ssm_parameter" "three_tier_ami" {
    name = "/production/ami"
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name = var.ssh_key
  public_key = tls_private_key.main.public_key_openssh  
}

resource "local_file" "ssh_key" {
  content = tls_private_key.main.private_key_openssh
  filename = "${var.ssh_key}-pem"
  file_permission = "0400"
}

data "aws_alb_target_group" "three_tier_tg" {
    name = var.lb_tg_name
}


resource "aws_launch_template" "three_tier_bastion" {
  name_prefix = "three_tier_bastion"
  instance_type = var.instance_type
  image_id = data.aws_ssm_parameter.three_tier_ami.value
  vpc_security_group_ids = [var.bastion_sg]
  key_name = var.key_name

  tags = {
    "Name" = "three_tier_bastion"
  }
}

resource "aws_autoscaling_group" "three_tier_bastion" {
  name = "three_tier_bastion"
  min_size = 1
  max_size = 1
  desired_capacity = 1
  vpc_zone_identifier = var.public_subnets

  launch_template {
    id = aws_launch_template.three_tier_bastion.id
    version = "$Latest"
  }
}

#launch template for frontend

resource "aws_launch_template" "three_tier_app" {
  name_prefix = "three_tier_app"
  instance_type = var.instance_type
  image_id = data.aws_ssm_parameter.three_tier_ami.value
  vpc_security_group_ids = [var.frontend_app_sg]
  key_name = var.key_name

  user_data = filebase64("install_apache.sh")

  tags = {
    "Name" = "three_tier_app"
  }
}


resource "aws_autoscaling_group" "three_tier_app" {
  name = "three_tier_app"
  min_size = 2
  max_size = 3
  desired_capacity = 2
  vpc_zone_identifier = var.public_subnets

  target_group_arns = [data.aws_alb_target_group.three_tier_tg.arn]

  launch_template {
    id = aws_launch_template.three_tier_app.id
    version = "$Latest"
  }
}


#launch template for backend

resource "aws_launch_template" "three_tier_backend" {
  name_prefix = "three_tier_backend"
  instance_type = var.instance_type
  image_id = data.aws_ssm_parameter.three_tier_ami.value
  vpc_security_group_ids = [var.backend_app_sg]
  key_name = var.key_name

  user_data = filebase64("install_node.sh")

  tags = {
    "Name" = "three_tier_backend"
  }
}

resource "aws_autoscaling_group" "three_tier_backend" {
  name = "three_tier_backend"
  min_size = 2
  max_size = 3
  desired_capacity = 2
  vpc_zone_identifier = var.private_subnets

  target_group_arns = [data.aws_alb_target_group.three_tier_tg.arn]

  launch_template {
    id = aws_launch_template.three_tier_backend.id
    version = "$Latest"
  }
}