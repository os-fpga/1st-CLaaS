# This Terraform file is used for all 1st-CLaaS EC2 instances.
# These boolean variables select the type and are used to condition resources.

# Configuration state is stored on your AWS S3 bucket.
terraform {
  backend "s3" {
    bucket = "<<S3_BUCKET>>"
    key    = "<<S3_KEY>>"
    region = "<<REGION>>"
  }
}

# Local directory of Git repository.
variable "repo_dir" {
  type = string
}

# URL from which repository can be cloned.
variable "git_url" {
  type = string
}

variable "git_branch" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "region" {
  type = string
}
# TODO: Region is hardcoded in files/aws_config/config.
# Instead, create the file using remote-exec and "cat", using the variable.
# TODO: Also, automate creation of aws_config.tfvars from AWS config file.


# Server Configuration Variables
# These are uploaded to the instance in a configuration file.
# Kernel name, corresponding to /apps/<kernel-name>.
variable "kernel" {
  type = string
  default = "NO_ASSOCIATED_KERNEL"
}
# Administrative password may be used in various ways by the webserver to authenticate administrative functions.
variable "admin_pwd" {
  type = string
}

variable "aws_config_path" {
  type = string
  default = "~/.aws/config"
}

variable "instance_type" {
  type = string
}

variable "instance_name" {
  type = string
  default = "UNNAMED"
}

# true/false for PREBUILT Makefile variable.
variable "use_prebuilt_afi" {
  type = string
  default = "false"
}

# Directory for output files, including TLS keys.
variable "out_dir" {
  type = string
  default = "."
}

# GB of block storage associated with the instance, mounted as /dev/sda1 and /.
variable "root_device_size" {
  type = number
  default = 65
}

# GB of block storage associated with the instance, mounted as /dev/sdb and /home/centos/src/project_data.
# Default size is for development. (AMI's default is 5, but we found this to be limited.)
# Use smaller for deployment.
variable "sdb_device_size" {
  type = number
  default = 15
}

# Delete storage (configured by root_device_size and sdb_device_size) when instance is deleted.
variable "delete_storage_on_destroy" {
  type = bool
  default = true
}

# The single script within the remotely-installed repo to initialize the instance.
# If this is overridden, the replacement script can call this default one.
variable "config_instance_script" {
  type = string
  default = "/home/centos/src/project_data/repo/framework/terraform/config_instance_dummy.sh"
}

resource "tls_private_key" "temp" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "for_${var.instance_name}"
  public_key = "${tls_private_key.temp.public_key_openssh}"
}

provider "aws" {
  #profile = "${var.aws_profile}"
  region                  = "${var.region}"
  access_key              = "${var.aws_access_key_id}"
  secret_key              = "${var.aws_secret_access_key}"
}

data "aws_ami" "instance_ami" {
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

resource "aws_security_group" "allow_webdev_80_ssh_rdp" {
    name        = "for_${var.instance_name}"
    description = "Allow HTTP inbound traffic (devel and production), SSH, and RDP"
  
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
      from_port   = 3389
      to_port     = 3389
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


resource "aws_instance" "the_instance" {
    ami           = "${data.aws_ami.instance_ami.id}"
    instance_type =  var.instance_type
    key_name      =  "for_${var.instance_name}"
    vpc_security_group_ids = ["${aws_security_group.allow_webdev_80_ssh_rdp.id}"]

    connection {
      type = "ssh"
      host = self.public_ip
      user = "centos"
      private_key = "${tls_private_key.temp.private_key_pem}"
    }

    root_block_device {
      volume_type = "gp2"
      volume_size = var.root_device_size
      delete_on_termination = var.delete_storage_on_destroy
    }

    ebs_block_device {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = var.sdb_device_size
      delete_on_termination = var.delete_storage_on_destroy
    }
  
    tags = {
      Name = "${var.instance_name}"
    }
    
    # Save TLS keys.
    provisioner "local-exec" {
      environment = {
        PRIVATE_KEY_PEM = "${tls_private_key.temp.private_key_pem}"
      }
      command ="mkdir -p ${var.out_dir} && echo \"$PRIVATE_KEY_PEM\" > ${var.out_dir}/private_key.pem"
    }
    provisioner "local-exec" {
      command ="chmod 600 ${var.out_dir}/private_key.pem"
    }
    provisioner "local-exec" {
      environment = {
        PUBLIC_KEY_PEM = "${tls_private_key.temp.public_key_pem}"
      }
      command ="echo \"$PUBLIC_KEY_PEM\" > ${var.out_dir}/public_key.pem"
    }
    provisioner "local-exec" {
      command ="chmod 600 ${var.out_dir}/public_key.pem"
    }
    
    # Because of a Terraform bug (https://github.com/hashicorp/terraform/issues/16330).
    # (What about privs? Should be 600?)
    provisioner "remote-exec" {
      inline = ["mkdir /home/centos/.aws"]
    }

    provisioner "file" {
      source      = "${pathexpand(var.aws_config_path)}"
      destination = "/home/centos/.aws/config"
    }
    
    provisioner "file" {
      content     = "[${var.aws_profile}] \n aws_access_key_id = ${var.aws_access_key_id} \n aws_secret_access_key = ${var.aws_secret_access_key}" 
      destination = "/home/centos/.aws/credentials"
    }
    
    #provisioner "file" {
    #  source      = "${var.repo_dir}/framework/terraform/clone_repos.sh"
    #  destination = "/home/centos/clone_repos.sh"
    #}
    
    # A private configuration file controlling the behavior of this instance.
    # Note: This contains a plain-text password, accessible to anyone with access to the machine.
    provisioner "file" {
      content     = "KERNEL_NAME=${var.kernel}; ADMIN_PWD=${var.admin_pwd}; USE_PREBUILT_AFI=${var.use_prebuilt_afi}"
      destination = "/home/centos/server_config.sh"
    }
    
    #provisioner "remote-exec" {
    #  inline = ["source '/home/centos/clone_repos.sh'"]
    #}
    
    # Configure instance.
    provisioner "remote-exec" {
      inline = [
        "echo && echo -e '\\e[32m\\e[1mSetting up remote instance.\\e[0m' && echo",
        "echo 'Cloning AWS-FPGA repo'",
        "git clone -q https://github.com/aws/aws-fpga.git $AWS_FPGA_REPO_DIR",
        "echo 'Cloning 1st CLaaS project repo'",  # 1st CLaaS repo or project repo using it.
        "git clone -q -b ${var.git_branch} '${var.git_url}' \"/home/centos/src/project_data/repo\"",
        "ln -s /home/centos/src/project_data /home/centos/workdisk",
        "ln -s /home/centos/src/project_data/repo /home/centos/repo",
        # If project repo (1st CLaaS repo or one that uses it) contains ./init, run it.
        "if [[ -e '/home/centos/src/project_data/repo/init' ]]; then echo 'Running init' && /home/centos/src/project_data/repo/init; fi",
        #"sudo /home/centos/src/project_data/repo/init",
        "echo && echo -e '\\e[32m\\e[1mCustomizing instance by running (remotely): \"${var.config_instance_script}\"\\e[0m' && echo",
        "source ${var.config_instance_script} ${aws_instance.the_instance.public_ip}",
      ]
    }
}

output "ip" {
  value = aws_instance.the_instance.public_ip
}

output "instance_id" {
  value = aws_instance.the_instance.id
}
