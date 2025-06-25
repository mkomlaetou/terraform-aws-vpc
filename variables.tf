variable "vpc_name" {
  description = "vpc name"
  type        = string
}

variable "aws_region" {
  description = "aws region "
  type        = string
}

variable "vpc_cidr" {
  description = "vpc network address (cidr)"
  type        = string
  default     = ""
}

variable "enable_igw" {
  description = "enable internet gateway"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "enable Nat Gateway (if set to 'true' enable_nat_instance must be set to 'false')"
  type        = bool
  default     = false
}

variable "enable_nat_instance" {
  description = "deploy an nat_instance (if set to 'true', enable_nat_gateway must be set to 'false')"
  type        = bool
  default     = false
}

variable "nat_subnet_name" {
  description = "public subnet for nat_gateway or nat_instance"
  type        = string
  default     = null
}


variable "subnets" {
  description = "subnet in the respective az"
  type        = map(tuple([string, string, string]))
  # default = {
  #   "priv-subnet-01" = ["a", "172.16.1.0/24", "private"]
  #   "pub-subnet-01"  = ["a", "172.16.10.0/24", "public"]
  # }
}


variable "nat_instance_details" {
  description = "nat_instance details. required if var.enable_nat_instance = true"
  type = object({
    platform      = optional(string, "ubuntu")
    os_version    = optional(string, "*22.04")
    architecture  = optional(string, "amd64")
    instance_type = optional(string, null)
    key_name      = optional(string)
    public_access = optional(bool, false) // to allow temporary public ssh access to nat_instance
  })
  default = {}

}


variable "custom_tags" {
  description = "additional custom tags"
  type        = map(string)
  default     = {}
}

