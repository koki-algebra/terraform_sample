/* ----- VPC ----- */
resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "${var.project_name}_vpc"
  }
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.project_name}_private_subnet_1a"
  }
}

resource "aws_subnet" "private_subnet_1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.project_name}_private_subnet_1b"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
}

/* ----- EC2 Instance Connect Endpoint ----- */
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
  subnet_id          = aws_subnet.private_subnet_1a.id
  security_group_ids = [aws_security_group.eice_sg.id]
  preserve_client_ip = true

  tags = {
    Name = "${var.project_name}_eice"
  }
}

/* ----- EC2 Instance ----- */
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

resource "aws_instance" "instance" {
  ami             = var.instance_ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private_subnet_1a.id
  security_groups = [aws_security_group.instance_sg.id]
}

/* RDS */
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}_rds_sg"
  description = "Security Group for RDS"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.project_name}_subnet_group"
  description = "Subnet Group for RDS"
  subnet_ids  = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1b.id]
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier     = "eice"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  engine         = var.db_engine
  engine_version = var.db_engine_version
  allow_major_version_upgrade = true

  database_name   = var.db_database_name
  master_username = var.db_user
  master_password = var.db_password

  // for dev
  skip_final_snapshot = true
  apply_immediately = true
}

resource "aws_rds_cluster_instance" "rds_cluster_instance" {
  identifier         = "eice"
  cluster_identifier = aws_rds_cluster.rds_cluster.id

  engine         = aws_rds_cluster.rds_cluster.engine
  engine_version = aws_rds_cluster.rds_cluster.engine_version
  instance_class = var.db_instance_class

  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
}
