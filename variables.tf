variable "location_name_long" {
  type        = string
  default     = "West Europe"
  description = "Azure location for all resources"
}

variable "location" {
  type        = string
  default     = "we"
  description = "Location short reference"
}

variable "location_name" {
  type        = string
  default     = "westeurope"
  description = "Location name long reference"
}

variable "env" {
  type        = string
  default     = "sbx"
  description = "Sandbox environment reference"
}


variable "base_name" {
  type        = string
  default     = "demo"
  description = "Base name for all resources"
}


variable "hub_vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "spoke_aks_vnet_cidr" {
  type    = string
  default = "10.1.0.0/16"
}