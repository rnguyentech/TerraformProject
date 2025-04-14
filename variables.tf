variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "West US 2"
}

variable "rg_name" {
  description = "Name of the resource group."
  type        = string
  default     = "terraformproject-dev"
}

variable "project_prefix" {
  description = "Prefix used by the naming module."
  type        = string
  default     = "tfproj"
}

variable "secret_ttl_hours" {
  description = "Lifetime of the Key Vault secret in hours."
  type        = number
  default     = 8760   # 1 year
}

variable "container_image" {
  description = "Docker image for the container instance."
  type        = string
  default     = "nginx:latest"
}

variable "container_cpu" {
  description = "vCPU allocation for the container."
  type        = number
  default     = 1
}

variable "container_memory" {
  description = "Memory (GB) allocation for the container."
  type        = number
  default     = 2
}