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

########################
# Container image
########################
variable "container_image" {
  description = "Image name and tag, e.g. library/nginx:latest"
  type        = string
}

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

########################
# Optional – Docker Hub / ACR credentials
########################
variable "docker_registry_server" {
  description = "Registry FQDN (index.docker.io for Docker Hub, <acr>.azurecr.io for ACR)"
  type        = string
  default     = "index.docker.io"
}

variable "docker_registry_username" {
  description = "Registry username (blank if public image)"
  type        = string
  default     = ""
}

variable "docker_registry_password" {
  description = "Registry password / PAT"
  type        = string
  sensitive   = true
  default     = ""
}

########################
# Example secret value
########################
variable "some_secret_value" {
  description = "Sample secret to store in Key Vault"
  type        = string
  sensitive   = true
}