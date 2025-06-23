## PURPOSE

This module allows you to create an IPv4 AWS VPC with the following 
* One IGW by default
* One Nat Gateway or Nat Instance 
* As many subnets (AZ)
* Automatic custom route to IGW for public subnet and Nat Gateway/Instance for private subnet

## MODULE FILE STRUCTURE

* vpc_main.tf : contains resource definition for VPC, IGW, Subnets, Routes and Route association (public & private)
* nat_main.tf : contains resource definition for NAT Gateway, NAT Instance and corresponding Security Group, NAT Public_IP
* variables.tf : contains all resources variables
* local.tf : contains default tags local variable and local variable for Nat_Instance instance type
* version.tf : contains terraform version and provider version
* output.tf : contains the output of the created Resources IDs

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.nat_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.nat_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.nat_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route_table.priv_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.pub_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.nat_ec2_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_ami.ubuntu_os](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | aws region | `string` | n/a | yes |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | additional custom tags | `map(string)` | `{}` | no |
| <a name="input_enable_igw"></a> [enable\_igw](#input\_enable\_igw) | enable internet gateway | `bool` | `true` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | enable Nat Gateway (if set to 'true' enable\_nat\_instance must be set to 'false') | `bool` | `false` | no |
| <a name="input_enable_nat_instance"></a> [enable\_nat\_instance](#input\_enable\_nat\_instance) | deploy an nat\_instance (if set to 'true', enable\_nat\_gateway must be set to 'false') | `bool` | `false` | no |
| <a name="input_nat_ingress"></a> [nat\_ingress](#input\_nat\_ingress) | n/a | `map(tuple([number, number, string]))` | <pre>{<br/>  "http": [<br/>    80,<br/>    80,<br/>    "tcp"<br/>  ],<br/>  "https": [<br/>    443,<br/>    443,<br/>    "tcp"<br/>  ],<br/>  "ssh": [<br/>    22,<br/>    22,<br/>    "tcp"<br/>  ]<br/>}</pre> | no |
| <a name="input_nat_instance_details"></a> [nat\_instance\_details](#input\_nat\_instance\_details) | nat\_instance details. required if var.enable\_nat\_instance = true | <pre>object({<br/>    platform      = optional(string, "ubuntu")<br/>    os_version    = optional(string, "*22.04")<br/>    architecture  = optional(string, "amd64")<br/>    instance_type = optional(string, null)<br/>    key_name      = optional(string)<br/>    public_access = optional(bool, false) // to allow temporary public ssh access to nat_instance<br/>  })</pre> | `{}` | no |
| <a name="input_nat_subnet_name"></a> [nat\_subnet\_name](#input\_nat\_subnet\_name) | public subnet for nat\_gateway or nat\_instance | `string` | `null` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | subnet in the respective az | `map(tuple([string, string, string]))` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | vpc ne twork address (cidr) | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | vpc name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_details"></a> [vpc\_details](#output\_vpc\_details) | n/a |


## SAMPLE ROOT MODULE

```hcl

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.0"
    }
  }
}

provider "aws" {
  region = var.vpc-01.region
  default_tags {
    tags = var.custom_tags
  }
}


##########################################
## SET UP NETWORK
##########################################
module "vpc-01" {
  # source             = "git::github.com/mkomlaetou/terraform-aws-vpc.git?ref=v1.0.1"
  source             = "../modules/terraform-aws-vpc"
  vpc_name           = var.vpc-01.name
  aws_region         = var.vpc-01.region
  vpc_cidr           = var.vpc-01.cidr
  subnets            = var.vpc-01_subnets
  enable_nat_gateway = var.vpc-01.ngw
  nat_subnet_name    = var.vpc-01.ngw_sb_name
}


// VPC details
variable "vpc-01" {
  default = {
    name          = "xyz-vpc-01"
    region        = "eu-west-1"
    cidr          = "10.19.0.0/16"
    igw           = true
    ngw           = false
    ngw_sb_name = "public-subnet-01"
  }
}


// AZ variables
variable "vpc-01_subnets" {
  #   type = map(tuple([string, string, string]))
  default = {
    // "network_name" = ["az_letter", "network_cidr", "type, private or public"]
    "public-subnet-01"  = ["a", "10.19.1.0/24", "public"]
    "public-subnet-02"  = ["b", "10.19.2.0/24", "public"]
    "public-subnet-03"  = ["c", "10.19.3.0/24", "public"]
    "private-subnet-01" = ["a", "10.19.10.0/24", "private"]
    "private-subnet-02" = ["b", "10.19.20.0/24", "private"]
    "private-subnet-03" = ["c", "10.19.30.0/24", "private"]
  }
}



// Custom tags
variable "custom_tags" {
  default = {
    IACTool     = "terraform"
    Environment = "lab"
    Purpose     = "aws-training"
  }
}



## VPC DETAILS OUTPUT
output "vpc-01_details" {
  value = module.vpc-01.vpc_details
}


```
