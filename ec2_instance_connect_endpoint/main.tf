resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "${var.project_name}_vpc"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.16.0.0/24"

  tags = {
    Name = "${var.project_name}_private_subnet"
  }
}

resource "aws_route_table" "name" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group" "eice_sg" {
  name        = "${var.project_name}_eice_sg"
  description = "Security Group for EC2 Instance Connect Endpoint"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ec2_instance_connect_endpoint" "instance_connect_endpoint" {
  subnet_id          = aws_subnet.private_subnet.id
  security_group_ids = [aws_security_group.eice_sg.id]
  preserve_client_ip = true

  tags = {
    Name = "${var.project_name}_eice"
  }
}

resource "aws_instance" "instance" {
  ami             = var.instance_ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.eice_sg.id]
}

resource "aws_security_group" "instance_sg" {
  name        = "${var.project_name}_instance_sg"
  description = "Security Group for EC2 Instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
