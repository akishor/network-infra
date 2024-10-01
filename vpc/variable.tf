variable "name" {
    type = string
}

variable "cidr_block" {
    type = string
}

variable "cidr_public_block" {
    type = string
}

variable "cidr_private_block" {
    type = string
}

variable "cidr_public_newbits" {
    type = number
    default = 4
}

variable "cidr_private_newbits" {
    type = number
    default = 2
}

variable "nat_ha_gateway" {
    type = bool
    default = true
}

variable "principal" {
    type = number
}