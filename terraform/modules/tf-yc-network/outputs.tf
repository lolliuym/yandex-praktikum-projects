output "network_id" {
  value       = yandex_vpc_network.network.id
  description = "The ID of the VPC network"
}

output "subnet_ids" {
  value = {
    for subnet in yandex_vpc_subnet.subnet : subnet.zone => subnet.id
  }
  description = "A map of subnet IDs per availability zone"
}