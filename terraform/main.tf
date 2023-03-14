provider "aws" {
    region = "${var.aws_region}"
}

terraform {
  required_version = "<= 2.0.14" #Forcing which version of Terraform needs to be used
  required_providers {
    aws = {
      version = "<= 4.0.0" #Forcing which version of plugin needs to be used.
      source = "hashicorp/aws"
    }
  }
}
resource "aws_s3_bucket" "terra_mpr" {
   bucket = "terraform-mpr-devops"
} 
resource "aws_s3_object" "alien" {
   bucket = aws_s3_bucket.terra_mpr.id
   key = "press.tfstate/"
} 


resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "my-vpc"
  }
}
resource "aws_internet_gateway" "my-IGW" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-IGW"
  }
}

resource "aws_subnet" "my-pub-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "my-pub-1"
  }
}


resource "aws_route_table" "my-pub-RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-IGW.id
  }

  tags = {
    Name = "my-pub-RT"
  }
}


resource "aws_route_table_association" "my-pub-1-a" {
  subnet_id      = aws_subnet.my-pub-1.id
  route_table_id = aws_route_table.my-pub-RT.id
}

resource "aws_security_group" "my-sg" {
  vpc_id      = aws_vpc.main.id
  name        = "my-sg"
  description = "Sec Grp for my ssh"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow-ssh"
  }
}






