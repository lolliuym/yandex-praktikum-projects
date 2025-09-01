variable "instance_name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "zone" {
  type        = string
  description = "Compute zone"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}

variable "image_id" {
  type        = string
  description = "Image ID"
}

variable "platform_id" {
  type        = string
  description = "Platform ID"
}

variable "disk_size_gb" {
  type        = number
  description = "Disk size in GB"
}

variable "user_data" {
  type        = string
  description = "Cloud-init user data"
}