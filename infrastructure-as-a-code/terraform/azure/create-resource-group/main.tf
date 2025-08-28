terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.119"
    }
  }
}

provider "azurerm" {
  features {}
  # Auth: via AZ CLI / Env / Managed Identity — pick your normal workflow
  # subscription_id = var.subscription_id
}

# Create an azurerm_resource_group for each entry in var.rgs
resource "azurerm_resource_group" "rg" {
  for_each = var.rgs

  name     = each.value.name
  location = each.value.location
  tags     = merge(var.default_tags, lookup(each.value, "tags", {}))
}

output "rg_ids" {
  description = "Map of RG names to IDs"
  value       = { for k, rg in azurerm_resource_group.rg : k => rg.id }
}
