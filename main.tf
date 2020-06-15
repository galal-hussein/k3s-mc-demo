terraform {
  backend "local" {
    path = "demo.tfstate"
  }
}

locals {
  name                      = var.name
}

provider "aws" {
  region  = "us-east-2"
  profile = "rancher-eng"
}

resource "aws_security_group" "k3s" {
  name   = "${local.name}-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k3s-demo" {
  count = "${var.instance_count}"
  instance_type = "t3.large"
  ami           = data.aws_ami.ubuntu.id
	key_name      = "hussein"
  security_groups = [
    aws_security_group.k3s.name,
  ]

   root_block_device {
    volume_size = "30"
    volume_type = "gp2"
  }

   tags = {
    Name = "${local.name}-demo-${count.index}"
  }
  provisioner "local-exec" {
      command = "sleep 10"
  }
}
