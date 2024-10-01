# Create VPC
module "vpc" {
    source = "./vpc"
    name = "main"
    cidr_block = var.cidr_block
    cidr_public_block = var.cidr_public_block
    cidr_private_block = var.cidr_private_block
    nat_ha_gateway = true
    principal = var.principal
}