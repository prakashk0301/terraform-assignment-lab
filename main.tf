provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_vpc" "my_custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my Custom VPC"
  }
}

resource "aws_subnet" "my_public_subnet1" {
  vpc_id            = aws_vpc.my_custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "my Public Subnet1"
  }
}

resource "aws_subnet" "my_public_subnet2" {
  vpc_id            = aws_vpc.my_custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "my Public Subnet2"
  }
}

resource "aws_internet_gateway" "my_ig" {
  vpc_id = aws_vpc.my_custom_vpc.id

  tags = {
    Name = "my Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.my_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = [ "aws_subnet.my_public_subnet1.id" , "aws_subnet.my_public_subnet2.id" ]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name   = "HTTP , HTTPS, and SSH"
  vpc_id = aws_vpc.my_custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_instance1" {
  ami           = "ami-04e601abe3e1a910f"
  instance_type = "t2.nano"
  key_name      = "devops-june"

  subnet_id                   = aws_subnet.my_public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash -ex

  sudo apt-get update -y
  sudo apt-get install apache2 -y
  sudo systemctl start apache2
  sudo systemctl enable apache2

  tags = {
    "Name" : "web_instance1"
  }
}

resource "aws_instance" "web_instance2" {
  ami           = "ami-04e601abe3e1a910f"
  instance_type = "t2.nano"
  key_name      = "devops-june"

  subnet_id                   = aws_subnet.my_public_subnet2.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash -ex

  sudo apt-get update -y
  sudo apt-get install apache2 -y
  sudo systemctl start apache2
  sudo systemctl enable apache2

  tags = {
    "Name" : "web_instance2"
  }
}
