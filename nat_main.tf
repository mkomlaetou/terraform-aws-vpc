##########################
# NAT-GATEWAT CREATION
##########################

// Create an EIP for Nat_Gateway or Nat_Instance
resource "aws_eip" "nat_ip" {
  count = var.enable_nat_gateway == true || var.enable_nat_instance == true ? 1 : 0

  domain = "vpc"

  tags = merge(local.tags, tomap({ "Name" : "${var.vpc_name}-nat_ip" }))

}

// NAT GATEWAY
// Create an Nat Gateway if var.enable_nat_instance = true
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway == true ? 1 : 0

  allocation_id = aws_eip.nat_ip[0].id
  subnet_id     = aws_subnet.main["${var.nat_subnet_name}"].id

  tags = merge(local.tags, tomap({ "Name" : "${var.vpc_name}-ngw" }))

  depends_on = [aws_internet_gateway.main]
}



##########################
# NAT EC2 INSTANCE
##########################

// Query ubuntu AMI for Nat_instance use
data "aws_ami" "ubuntu_os" {
  count       = var.enable_nat_instance == true ? 1 : 0
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.nat_instance_details.os_version}-${var.nat_instance_details.architecture}-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


// Create a NAT INSTANCE if var.enable_nat_instance = true
resource "aws_instance" "nat_ec2" {
  count                       = var.enable_nat_instance == true ? 1 : 0
  ami                         = data.aws_ami.ubuntu_os[0].id
  instance_type               = local.nat_instance_type
  tenancy                     = "default"
  availability_zone           = aws_subnet.main["${var.nat_subnet_name}"]["availability_zone"]
  subnet_id                   = aws_subnet.main["${var.nat_subnet_name}"].id
  associate_public_ip_address = true

  source_dest_check       = false
  disable_api_termination = false
  key_name                = var.nat_instance_details.key_name
  vpc_security_group_ids  = [aws_security_group.nat_ec2_sg[0].id]
  user_data               = file("${path.module}/user_data/user_data.sh")

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
    tags                  = merge(local.tags, tomap({ "Name" : "nat-ec2_root-vol" }))
  }

  tags = merge(local.tags, tomap({ "Name" : "nat-ec2" }))

  lifecycle {
    ignore_changes = [ami, associate_public_ip_address]
  }
  depends_on = [aws_eip.nat_ip]
}


resource "aws_eip_association" "nat_ec2" {
  count         = var.enable_nat_instance == true ? 1 : 0
  instance_id   = aws_instance.nat_ec2[0].id
  allocation_id = aws_eip.nat_ip[0].id
}



#######################
# CREATE SECURITY GROUP
#######################

// query my ip
data "http" "myip" {
  count = var.nat_instance_details.public_access == true ? 1 : 0
  url   = "https://icanhazip.com"
}
locals {
  my_ip = var.nat_instance_details.public_access == true ? "${chomp(data.http.myip[0].response_body)}/32" : ""
}

resource "aws_security_group" "nat_ec2_sg" {
  count = var.enable_nat_instance == true ? 1 : 0

  name        = "nat-ec2-sg"
  description = "Security Group"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.nat_ingress
    content {
      from_port   = ingress.value[0]
      to_port     = ingress.value[1]
      protocol    = ingress.value[2]
      cidr_blocks = var.nat_instance_details.public_access == true ? [var.vpc_cidr, local.my_ip] : [var.vpc_cidr]
      description = ingress.key
    }
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "all_outbound"
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "all_outbound"
  }

  tags = merge(local.tags, tomap({ "Name" : "nat-ec2-sg" }))

  timeouts {
    delete = "2m"
  }

  lifecycle {
    create_before_destroy = true
  }
}

variable "nat_ingress" {
  type = map(tuple([number, number, string]))
  default = {
    "http"  = [80, 80, "tcp"]
    "https" = [443, 443, "tcp"]
    "ssh"   = [22, 22, "tcp"]
  }
}

