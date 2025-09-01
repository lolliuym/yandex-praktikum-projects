output "instance_external_ip" {
  value       = yandex_compute_instance.default.network_interface.0.nat_ip_address
  description = "The external IP address of the instance"
}