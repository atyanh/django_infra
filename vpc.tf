# Create VPC
resource "aws_vpc" "vpc" {
  
  cidr_block      = "10.0.0.0/16"

  tags = {
    Name          = "my_vpc"
  }
}


# Create Subnet
resource "aws_subnet" "subnet" {
  
  vpc_id          = aws_vpc.vpc.id
  cidr_block      = "10.0.1.0/24"

  tags = {
    Name = "my_subnet"
  }
}




# Create route table
resource "aws_route_table" "r_table" {
  
  vpc_id          = aws_vpc.vpc.id

  route {
    cidr_block    = "0.0.0.0/0"
    gateway_id    = aws_internet_gateway.gw.id
  }
  
  tags = {
    Name          = "rout_table"
  }
}


# Create route table association
resource "aws_route_table_association" "aws_rtb_assoc" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.r_table.id
  
  
}




# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
 
  vpc_id          = aws_vpc.vpc.id

  tags = {
    Name          = "internet_gateway"
  }
}

  

# Created Security_Group
resource "aws_security_group" "sec_group" {
  name              = "Dynamic_security_group"
  vpc_id            = aws_vpc.vpc.id


dynamic "ingress" {
  for_each = ["22"]
  content {
    from_port        = ingress.value
    to_port          = ingress.value
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
}
  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "Security_group"
  }
}