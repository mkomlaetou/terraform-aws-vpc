##########################
# VPC CREATION
##########################

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = merge(local.tags, tomap({ "Name" : var.vpc_name }))
}

##########################
# IGW CREATION
##########################
resource "aws_internet_gateway" "main" {
  count  = var.enable_igw == true ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, tomap({ "Name" : "${var.vpc_name}-igw" }))
}




##########################
# SUBNETS CREATION
##########################
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  for_each          = var.subnets
  availability_zone = "${var.aws_region}${each.value[0]}"
  cidr_block        = each.value[1]

  tags = merge(local.tags, tomap({ "Name" : "${each.key}" }), tomap({ "subnet_type" : "${each.value[2]}" }))
}


// DEFAULT ROUTE FOR PUBLIC SUBNETS
resource "aws_route_table" "main_pub_rt" {
  count  = var.enable_igw == true ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(local.tags, tomap({ "Name" : "main_pub_rt" }))

}


##########################
# DEFAULT ROUTES 
##########################

// DEFAULT ROUTE FOR PRIVATE SUBNETS
resource "aws_route_table" "main_priv_rt" {
  count  = var.enable_nat_gateway == true || var.enable_nat_instance == true ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    nat_gateway_id       = var.enable_nat_gateway == true ? aws_nat_gateway.main[0].id : ""
    network_interface_id = var.enable_nat_instance == true ? aws_instance.nat_ec2[0].primary_network_interface_id : ""

  }
  tags = merge(local.tags, tomap({ "Name" : "main-priv-rt" }))
}


// ROUTE TABLE ASSOCIATION FOR PUBLIC SUBNETS
resource "aws_route_table_association" "public" {
  count          = length([for k, v in aws_subnet.main : k if lookup(v.tags, "subnet_type", "") == "public" && length(aws_route_table.main_pub_rt) > 0])
  subnet_id      = element([for k, v in aws_subnet.main : v.id if lookup(v.tags, "subnet_type", "") == "public"], count.index)
  route_table_id = aws_route_table.main_pub_rt[0].id
}

// ROUTE TABLE ASSOCIATION FOR PRIVATE SUBNETS
resource "aws_route_table_association" "private" {
  count          = length([for k, v in aws_subnet.main : k if lookup(v.tags, "subnet_type", "") == "private" && length(aws_route_table.main_priv_rt) > 0])
  subnet_id      = element([for k, v in aws_subnet.main : v.id if lookup(v.tags, "subnet_type", "") == "private" && length(aws_route_table.main_priv_rt) > 0], count.index)
  route_table_id = aws_route_table.main_priv_rt[0].id
}
