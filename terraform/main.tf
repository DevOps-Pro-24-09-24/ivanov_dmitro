provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/24"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.0.0/25"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.0.128/25"
}

resource "aws_security_group" "sg_FRONT" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_BACK" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.sg_FRONT.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-0b5673b5f6e8f7fa7"  # Обновите этот ID на действительный AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.sg_FRONT.id]  # Используйте идентификаторы групп безопасности

  tags = {
    Name = "WebInstance"
  }
}

resource "aws_instance" "db" {
  ami                    = "ami-0b5673b5f6e8f7fa7"  # Обновите этот ID на действительный AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.sg_BACK.id]  # Используйте идентификаторы групп безопасности

  tags = {
    Name = "DBInstance"
  }
}

output "web_instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "db_instance_private_ip" {
  value = aws_instance.db.private_ip
}

output "web_instance_dns" {
  value = aws_instance.web.public_dns
}
