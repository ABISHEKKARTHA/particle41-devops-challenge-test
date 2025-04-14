variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "simpletimeservice"
}

variable "address_space" {
  description = "VNet address space"
  type        = string
  default     = "10.0.0.0/16"
}

variable "container_image" {
  description = "Docker image for the application"
  type        = string
  default     = "youracrname.azurecr.io/simpletimeservice:latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 5000
}

variable "container_cpu" {
  description = "CPU cores for the container"
  type        = number
  default     = 1
}

variable "container_memory" {
  description = "Memory for the container in GB"
  type        = number
  default     = 1.5
}

variable "instance_count" {
  description = "Number of container instances"
  type        = number
  default     = 2
}