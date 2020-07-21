provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical

}

resource "aws_security_group" "sg" {
  name = "ssh-allow"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "type" = "ssh-allow-security-group"
  }

}

resource "aws_key_pair" "testkey1" {
  key_name   = "testkey1"
  public_key = file(var.publickey)
}

resource "aws_instance" "ubuntu" {
  ami             = data.aws_ami.ubuntu.id
  security_groups = [aws_security_group.sg.name]
  instance_type   = "t2.micro"
  key_name        = "testkey1"

}

resource "aws_ebs_volume" "vol-data" {
  availability_zone = "us-west-2a"
  size              = 1

  tags = {
    Name = "data-volume"
  }
}

resource "aws_volume_attachment" "ubuntu-vol" {
  device_name = "/dev/sdh"
  volume_id   = "aws_ebs_volume.vol-data.id"
  instance_id = "aws_instance.ubuntu.id"

}

/*
resource "aws_ebs_snapshot" "example_snapshot" {
  volume_id = "aws_ebs_volume.vol-data.id"

  tags = {
    Name = "HelloWorld_snap"
  }
}
*/
output "ip_address" {
  value = aws_instance.ubuntu.public_ip
}

