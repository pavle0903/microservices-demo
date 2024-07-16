variable "name" {
  description = "Name"
  type = string
}

variable "region" {
  description = "Region"
  type = string
}

variable "network" {
  description = "vpc"
  type = string
}
variable "ip_cidr_range" {
  description = "IP CIDR range of the subnet"
  type = string
}