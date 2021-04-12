terraform {
	required_providers {
		azurerm = {
			source = "hashicorp/azurerm"
			version = "~> 2.51.0"
		}
	}
}

provider azurerm {
	features {}
}

resource random_string suffix {
  length = 4
  special = false 
  upper = false
  lower = true
  number = false
}

resource "random_password" "cert_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

locals {
	prefix = var.prefix
	suffix = random_string.suffix.result
	cert_password = random_password.cert_password.result
}