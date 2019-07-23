variable "key_name" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

# An administrative password that will be uploaded to the instance.
variable "admin_pwd" {
  type = string
}
variable "aws_config_path" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "region" {
  type = string
}
# TODO: Region is hardcoded in files/aws_config/config.
# Instead, create the file using remote-exec and "cat", using the variable.
# TODO: Also, automate creation of aws_config.tfvars from AWS config file.

variable "delete_storage_on_destroy" {
  type = bool
}

variable "app_launch_script" {
  type = string
  default = "/home/centos/terraform/dummy.sh"
}


resource "tls_private_key" "temp" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.temp.public_key_openssh}"
}

provider "aws" {
  region                  = "${var.region}"
  access_key              = "${var.aws_access_key_id}"
  secret_key              = "${var.aws_secret_access_key}"
}

data "aws_ami" "latest_fpgadev" {
most_recent = true
owners = ["679593333241"] 

  filter {
      name   = "name"
      values = ["FPGA Developer AMI - 1.6.0-40257ab5-6688-4c95-97d1-e251a40fd1fc-ami-0b1edf08d56c2da5c.4"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

resource "aws_security_group" "allow_web" {
    name        = "allow_web"
    description = "Allow HTTP inbound traffic"
  
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port   = 8880
      to_port     = 8889
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }
  }

resource "aws_instance" "fpga_f1" {
    ami           = "${data.aws_ami.latest_fpgadev.id}"
    instance_type =  var.instance_type
    key_name      =  "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.allow_web.id}"]

    connection {
      type = "ssh"
      host = self.public_ip
      user = "centos"
      private_key = "${tls_private_key.temp.private_key_pem}"
    }

    root_block_device {
      volume_type = "gp2"
      volume_size = 65
      delete_on_termination = var.delete_storage_on_destroy
    }

    ebs_block_device {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = 15
      delete_on_termination = var.delete_storage_on_destroy
    }
  
    tags = {
      Name = "FPGA_run"
    }
  
    provisioner "file" {
      source      = var.aws_config_path
      destination = "/home/centos/.aws/config"
    }
    provisioner "file" {
    content     = "[default] \n aws_access_key_id = ${var.aws_access_key_id} \n aws_secret_access_key = ${var.aws_secret_access_key}" 
    destination = "/home/centos/.aws/credentials"
    }
    provisioner "file" {
      source      = "files/scripts/init.sh"
      destination = "/home/centos/init.sh"
    }
    provisioner "file" {
      source      = "files/scripts/dummy.sh"
      destination = "/home/centos/dummy.sh"
    }
    # A password saved as plain text on the server that may be used in any way desired, such as privileged AWS operations like starting an F1 instance via REST.
    provisioner "file" {
      content     = var.admin_pwd
      destination = "/home/centos/admin_pwd.txt"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /home/centos/init.sh",
        "source /home/centos/init.sh",
      ]
    }
  
    provisioner "remote-exec" {
      inline = [
        "chmod +x /home/centos/dummy.sh",
        "source ${var.app_launch_script}",
        "sleep 1",
      ]
    }

    provisioner "local-exec" {
     command ="echo \"${tls_private_key.temp.private_key_pem}\" > private_key.pem"    
    }

    provisioner "local-exec" {
     command ="chmod 600 private_key.pem"    
    }

    provisioner "local-exec" {
     command ="echo \"${tls_private_key.temp.public_key_pem}\" > public_key.pem"    
    }

    provisioner "local-exec" {
     command ="chmod 600 public_key.pem"    
    }
}

output "ip" {
  value = aws_instance.fpga_f1.public_ip
}

# TODO: It would be nice to also output the instance ID.
