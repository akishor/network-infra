variable "cidr_block" {
    default = "10.0.0.0/16"
    type = string
}

variable "cidr_public_block" {
    default = "10.0.0.0/22"
    type = string
}

variable "cidr_private_block" {
    default = "10.0.4.0/22"
    type = string
}

variable "principal" {
    default = 885952650506
    type = number
}

variable "ver" {
    default = 3
    type = number
}