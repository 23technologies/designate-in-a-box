provider "openstack" {
  cloud = var.cloud_provider
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    local = {
      source = "hashicorp/local"
    }

    null = {
      source = "hashicorp/null"
    }

    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}
