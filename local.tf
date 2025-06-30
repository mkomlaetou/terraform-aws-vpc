# Tags
locals {
  default_tags = {
    IacTool = "terraform"
  }
  tags = merge(local.default_tags, var.custom_tags)
}


// set default nat instance type
locals {
  nat_instance_type = var.nat_instance_details.instance_type != null ? var.nat_instance_details.instance_type : var.nat_instance_details.architecture == "arm64" ? "t4g.micro" : "t3.micro"
}


