# Create 2 public subnets
resource "aws_subnet" "public_subnet_for_eks_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidr_1
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true

  tags = {
    "Name" = "Public Subnet for EKS 1"
  }
}

resource "aws_subnet" "public_subnet_for_eks_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidr_2
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true

  tags = {
    "Name" = "Public Subnet for EKS 2"
  }
}

# Creating Route table
resource "aws_route_table" "my_rtb" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    "Name" = "RTB from TF"
  }
}

# Associate it to subnets

resource "aws_route_table_association" "rtb_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_for_eks_1.id
  route_table_id = aws_route_table.my_rtb.id
}
resource "aws_route_table_association" "rtb_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_for_eks_2.id
  route_table_id = aws_route_table.my_rtb.id
}


# Creating Sec Group

resource "aws_security_group" "eks_vpc_sg" {
  name        = "sg_for_eks"
  description = "SG for EKS"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "value"
    from_port   = var.app_port
    protocol    = "TCP"
    to_port     = var.app_port
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "SG for EKS"
  }
}
