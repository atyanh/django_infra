# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "VPC for Django Project"
  }
}


# Create subnet
resource "aws_subnet" "ops_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.ops_subnet_cidr
  availability_zone = "us-east-1b"
  tags = {
    "Name" = "Subnet for Ops Server"
  }
}


# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    "Name" = "IGW For Django Project VPC"
  }
}

# Creating Route table
resource "aws_route_table" "ops_rtb" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    "Name" = "Rtb For Ops Subnet"
  }
}

# Associate it to subnet

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.ops_subnet.id
  route_table_id = aws_route_table.ops_rtb.id
}

# Creating Sec Group

resource "aws_security_group" "ops_sg" {
  name        = "allow_ssh"
  description = "SG for Ops"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "SSH open"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "WIREGUARD open"
    from_port        = 51820
    to_port          = 51820
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Jenkins open"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "For Docker"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "SG For Ops"
  }
}


# Configuaring Key pair

resource "aws_key_pair" "ops_key_pair" {
  key_name   = "My-Key-Pair"
  public_key = file(var.ssh_key_path)

  tags = {
    "Name" = "MyKeyPairFromTF"
  }
}

#Create instance

resource "aws_instance" "ops_server" {
  ami           = "ami-0149b2da6ceec4bb0"
  instance_type = "t3.xlarge"

  associate_public_ip_address = true
  subnet_id                   = aws_subnet.ops_subnet.id
  key_name                    = aws_key_pair.ops_key_pair.key_name

  tags = {
    "Name" = "OPS server"
  }

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = 20
  }

  security_groups = [aws_security_group.ops_sg.id]
}

output "instance_ip_addr" {
  value = aws_instance.ops_server.public_ip
}
output "instance_private_ip_addr" {
  value = aws_instance.ops_server.private_ip
}
output "instance_id" {
  value = aws_instance.ops_server.id
}
