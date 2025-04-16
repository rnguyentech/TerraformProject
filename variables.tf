########################
# Core settings
########################
variable "project_prefix" {
  description = "Short prefix used by the naming module (e.g. 'myproj')"
  type        = string
}

variable "rg_name" {
  description = "Name of the resource group to create"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westus2"
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "To enable telemetry"
}

########################
# Container image
########################

variable "container_cpu" {
  description = "vCPU cores for the container"
  type        = number
  default     = 0.5
}

variable "container_memory" {
  description = "Memory (GB) for the container"
  type        = number
  default     = 1
}

variable "docker_registry_server" {
  default = "index.docker.io"
  type    = string
}

variable "docker_registry_username" {
  type = string
}

variable "docker_registry_password" {
  type      = string
  sensitive = true
}

########################
# Example secret value
########################
variable "some_secret_value" {
  description = "Sample secret to store in Key Vault"
  type        = string
  sensitive   = true
}