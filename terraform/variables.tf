variable "token" {
  type        = string
  description = "Yandex Cloud OAuth token"
}

variable "cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "folder_id" {
  type        = string
  description = "Yandex Cloud folder ID"
}

variable "instance_name" {
  type        = string
  description = "Name of the virtual machine"
  default     = "test-vm"
}

variable "network_zones" {
  type        = list(string)
  description = "List of availability zones for the network"
  default     = ["ru-central1-a"]
}

variable "zone" {
  type        = string
  description = "Compute zone"
  default     = "ru-central1-a"
}

variable "image_id" {
  type        = string
  description = "Image ID"
  default = "fd8cqlvgvd2jf5j8qt8i"
}

variable "platform_id" {
    type = string
    description = "Platform ID"
    default = "standard-v1"
}

variable "scheduling_policy" {
    type = string
    description = "Scheduling Policy"
    default = "preemptible"
}

variable "disk_size_gb" {
    type = number
    description = "Disk Size Gb"
    default = 20
}
