
# Created Instance
resource "aws_instance" "my_project" {
  
  ami           = var.image 
  instance_type = var.type
  vpc_security_group_ids = [aws_security_group.sec_group.id]
  subnet_id   = aws_subnet.subnet.id
  key_name = aws_key_pair.ssh_key_pair.id
  associate_public_ip_address = true

  tags = {
    "Name" = "my_project"
  }  
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "ssh_key"
  public_key = file("./project.pub")

tags = {
    Name = "ssh_key"
  }
}
