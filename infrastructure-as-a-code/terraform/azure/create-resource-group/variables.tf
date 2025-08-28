variable "subscription_id" {
  description = "Optional explicit subscription id if not using CLI/MSI"
  type        = string
  default     = null
}

variable "default_tags" {
  description = "Tags applied to every RG by default"
  type        = map(string)
  default     = {
    managed-by = "terraform"
  }
}

variable "rgs" {
  description = <<DESC
Map of resource groups to create. Keys are arbitrary handles.
Each value must have:
  - name     : RG name
  - location : Azure region
  - tags     : (optional) map of tags
Example:
{
  dev1 = { name="viva-dev--1", location="eastus", tags={env="dev"} }
  dev2 = { name="viva-dev--2", location="eastus2" }
}
DESC
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
}
