/**
 * Default tags to apply to all resources. Merged with var.custom_tags.
 */

/**
 * Set nat instance type based on architecture if not specified.
 * Defaults to t3.micro on x86 and t4g.micro on arm64.
 */
 
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


