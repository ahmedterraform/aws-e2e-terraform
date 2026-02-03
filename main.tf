
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "me" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "aws-e2e-vpc"
    Project = "aws-e2e"
  }

}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { name = "aws-2e2-igw"
    Project = "aws-e2e"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name    = "aws-e2e-public-a"
    Project = "aws-e2e"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name    = "aws-e2e-public-b"
    Project = "aws-e2e"
  }
}
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name    = "aws-e2e-private-a"
    Project = "aws-e2e"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name    = "aws-e2e-private-b"
    Project = "aws-e2e"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name    = "aws-e2e-nat-eip"
    Project = "aws-e2e"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name    = "aws-e2e-nat"
    Project = "aws-e2e"
  }

  depends_on = [aws_internet_gateway.igw]
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "aws-e2e-rt-private"
    Project = "aws-e2e"
  }
}
resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
resource "aws_security_group" "alb_sg" {
  name        = "aws-e2e-alb-sg"
  description = "Allow HTTP from Internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "aws-e2e-alb-sg"
    Project = "aws-e2e"
  }
}
resource "aws_security_group" "ec2_sg" {
  name        = "aws-e2e-ec2-sg"
  description = "Allow HTTP from ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "aws-e2e-ec2-sg"
    Project = "aws-e2e"
  }
}
resource "aws_lb_target_group" "app_tg" {
  name     = "aws-e2e-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name    = "aws-e2e-tg"
    Project = "aws-e2e"
  }
}
resource "aws_lb" "alb" {
  name               = "aws-e2e-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name    = "aws-e2e-alb"
    Project = "aws-e2e"
  }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
