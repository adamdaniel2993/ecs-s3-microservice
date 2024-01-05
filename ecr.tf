locals {
  services_list = ["accountservice", "inventoryservice", "shippingservice"]
}

resource "aws_ecr_repository" "nova-ecrs" {
  for_each = toset(local.services_list)

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}