resource "aws_subnet" "db_subnet_1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.db_subnet_cidr_1
  availability_zone = "us-east-1b"
  tags = {
    "Name" = "Subnet for DB"
  }
}

resource "aws_subnet" "db_subnet_2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.db_subnet_cidr_2
  availability_zone = "us-east-1c"
  tags = {
    "Name" = "Subnet for DB"
  }

}

resource "aws_security_group" "db_sg" {
  name        = "sg_for_db"
  description = "SG for DB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "Postgre open"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

resource "aws_db_subnet_group" "subnet_group_for_db" {
  name       = "main"
  subnet_ids = [aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id]

  tags = {
    Name = "MDB subnet group"
  }
}

resource "aws_db_instance" "rds_db" {
  allocated_storage   = 20
  identifier          = "django"
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "12.7"
  instance_class      = "db.t3.micro"
  username            = "djangoproject"
  password            = "admin119"
  skip_final_snapshot = true
  vpc_security_group_ids = [ aws_security_group.db_sg.id ]

  db_subnet_group_name = aws_db_subnet_group.subnet_group_for_db.name
  db_name = "djangoproject"



  tags = {
    Name = "RDSServerInstanceForDjango"
  }
}

output "db_address" {
  value = aws_db_instance.rds_db.address
}