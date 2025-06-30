
output "vpc_details" {
  value = {
    vpc_id          = aws_vpc.main.id
    igw_id          = var.enable_igw == true ? aws_internet_gateway.main[0].id : "N/A"
    ngw_id          = var.enable_nat_gateway == true ? aws_nat_gateway.main[0].id : "N/A"
    nat_ip          = var.enable_nat_gateway == true || var.enable_nat_instance == true ? aws_eip.nat_ip[0].public_ip : "N/A"
    nat_instance_id = var.enable_nat_instance == true ? aws_instance.nat_ec2[0].id : "N/A"
    subnets_id      = { for k, y in aws_subnet.main : k => y.id }
    main_priv_rt         = var.enable_nat_gateway == true || var.enable_nat_instance == true ? aws_route_table.main_priv_rt[0].id : "N/A"
    main_pub_rt          = aws_route_table.main_pub_rt[0].id
  }
}
