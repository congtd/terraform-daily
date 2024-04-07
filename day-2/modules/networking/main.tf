resource "aws_vpc" "three_tier_vpc" {
  cidr_block           = var.vpc_cird
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "three_tier_vpc"
  }
}

# data "aws_availability_zones" "three_tier_azs" {

# }

resource "aws_internet_gateway" "three_tier_igw" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    "Name" = "three_tier_internet_gateway"
  }
}

# public subnet

resource "aws_subnet" "three_tier_public_subnets" {
  vpc_id                  = aws_vpc.three_tier_vpc.id
  count                   = var.public_subnet_count
  cidr_block              = "10.123.${10 + count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = element(var.azs, count.index)

  tags = {
    "Name" = "three_tier_public_subnet_${count.index + 1}"
  }
}

resource "aws_route_table" "three_tier_public_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    "Name" = "three_tier_public_rt"
  }
}

resource "aws_route_table_association" "three_tier_public_rt_assoc" {
  route_table_id = aws_route_table.three_tier_public_rt.id
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.three_tier_public_subnets[count.index].id
}

resource "aws_route" "public_subnet_rt" {
  route_table_id         = aws_route_table.three_tier_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.three_tier_igw.id
}

resource "aws_eip" "three_tier_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "three_tier_nat_gateway" {
  allocation_id = aws_eip.three_tier_eip.id
  subnet_id     = aws_subnet.three_tier_public_subnets[1].id
  tags = {
    "Name" = "threetier-nat-gw"
  }
}


#private subnet


resource "aws_subnet" "three_tier_private_subnets" {
  vpc_id                  = aws_vpc.three_tier_vpc.id
  count                   = var.private_subnet_count
  cidr_block              = "10.123.${20 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = element(var.azs, count.index)

  tags = {
    "Name" = "three_tier_private_subnets_${count.index + 1}"
  }
}


resource "aws_route_table" "three_tier_private_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.three_tier_nat_gateway.id
  }

  tags = {
    "Name" = "three_tier_private_rt"
  }
}

resource "aws_route_table_association" "three_tier_private_rt_assoc" {
  route_table_id = aws_route_table.three_tier_private_rt.id
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.three_tier_private_subnets[count.index].id
}


# private subnet for db

resource "aws_subnet" "three_tier_private_subnets_db" {
  vpc_id                  = aws_vpc.three_tier_vpc.id
  count                   = var.private_subnet_count
  cidr_block              = "10.123.${30 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = element(var.azs, count.index)

  tags = {
    "Name" = "three_tier_private_subnets_db_${count.index + 1}"
  }
}

# SG for lb

resource "aws_security_group" "three_tier_lb_sg" {
  name   = "three_tier_lb_sg"
  vpc_id = aws_vpc.three_tier_vpc.id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "for all go out traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}


# SG for bastion host

resource "aws_security_group" "three_tier_bastion_sg" {
  name   = "three_tier_bastion_sg"
  vpc_id = aws_vpc.three_tier_vpc.id

  ingress = [
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "HTTP"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "for all go out traffic"
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}


# SG FE

resource "aws_security_group" "three_tier_frontend_sg" {
  name   = "three_tier_frontend_sg"
  vpc_id = aws_vpc.three_tier_vpc.id

  ingress = [
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = []
      description      = "HTTP"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = [aws_security_group.three_tier_bastion_sg.id]
      self             = false
    },
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = []
      description      = "HTTP"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = [aws_security_group.three_tier_lb_sg.id]
      self             = false
    },

  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "for all go out traffic"
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}


# SG BE

resource "aws_security_group" "three_tier_backend_sg" {
  name   = "three_tier_backend_sg"
  vpc_id = aws_vpc.three_tier_vpc.id

  ingress = [
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = []
      description      = "HTTP"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = [aws_security_group.three_tier_bastion_sg.id]
      self             = false
    },
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = []
      description      = "HTTP"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = [aws_security_group.three_tier_frontend_sg.id]
      self             = false
    }
  ]


  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "for all go out traffic"
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}


# SG DB

resource "aws_security_group" "three_tier_db_sg" {
  name   = "three_tier_db_sg"
  vpc_id = aws_vpc.three_tier_vpc.id

  ingress = [
    {
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "HTTP"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "for all go out traffic"
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

resource "aws_db_subnet_group" "three_tier_db_subnetgroup" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "three_tier_db_subnetgroup"
  subnet_ids = [aws_subnet.three_tier_private_subnets_db[0].id, aws_subnet.three_tier_private_subnets_db[1].id]

  tags = {
    "Name" = "three_tier_db_subnetgroup"
  }
}
