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

locals {
	prefix = var.prefix
	suffix = var.suffix
}