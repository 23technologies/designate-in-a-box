variable "cloud_provider" {
  type = string
}

variable "prefix" {
  type    = string
  default = "designate-in-a-box"
}

variable "image" {
  type    = string
  default = "Ubuntu 20.04"
}

variable "flavor" {
  type    = string
  default = "4C-16GB-40GB"
}

variable "availability_zone" {
  type    = string
  default = "south"
}

variable "network_availability_zone" {
  type    = string
  default = "south"
}

variable "public" {
  type    = string
  default = "external"
}

variable "configuration_version" {
  type    = string
  default = "main"
}

variable "enable_config_drive" {
  type    = bool
  default = true
}

variable "dns_nameservers" {
  type    = list(string)
  default = ["1.1.1.1", "8.8.8.8", "9.9.9.9"]
}

variable "domain" {
  type    = string
  default = "gardener.23technologies.xyz"
}

variable "endpoint" {
  type    = string
  default = "api.designate-in-a-box.23technologies.xyz"
}
