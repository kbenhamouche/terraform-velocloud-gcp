// GCP variables

variable "gcp_project" {
  default = "direct-electron-288211"
}
variable "gcp_region" {
  description = "Enter your region (example: northamerica-northeast1 for Canada)"
  default = "northamerica-northeast1"
}

variable "gcp_zone" {
  description = "Enter your AWS availability zone (example: northamerica-northeast1a for Canada)"
  default = "northamerica-northeast1-a"
}

variable "public_sn_cidr_block" {
  description = "Enter the public subnet (example: 172.18.0.0/24)"
  default = "172.18.0.0/24"
}

variable "private_sn_cidr_block" {
  description = "Enter the private subnet (example: 172.18.100.0/24)"
  default = "172.18.100.0/24"
}

variable "mngt_sn_cidr_block" {
  description = "Enter the private subnet (example: 172.18.1.0/24)"
  default = "172.18.1.0/24"
}

variable "private_ip" {
  description = "Enter the private IP for the LAN interface (example: 172.18.100.100) - this IP has to be configured in VCO/Edge/Device as Corporate IP"
  default = "172.18.100.100"
}

variable "instance_type" {
  description = "Enter the instance type (example: n1-standard-4)"
  default = "n1-standard-4"
}

variable "vco" {
  default = "vco12-usvi1.velocloud.net"
}

variable "activation_code" {
  default = "2CMR-Y8AL-TJ73-TYRH"
}

