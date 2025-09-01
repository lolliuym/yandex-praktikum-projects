resource "yandex_vpc_network" "network" {
  name = "ansible-network"
}

resource "yandex_vpc_subnet" "subnet" {
  for_each = toset(var.network_zones)

  name           = "ansible-subnet-${each.value}"
  zone           = each.value
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = [cidrsubnet("192.168.0.0/16", 8, index(var.network_zones, each.value))]
}
