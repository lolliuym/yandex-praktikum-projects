output "instance_external_ip" {
  value       = module.tf-yc-instance.instance_external_ip
  description = "The external IP address of the instance"
}

output "network_id" {
  value       = module.tf-yc-network.network_id
  description = "The ID of the VPC network"
}

output "subnet_ids" {
  value       = module.tf-yc-network.subnet_ids
  description = "A map of subnet IDs per availability zone"
}
 