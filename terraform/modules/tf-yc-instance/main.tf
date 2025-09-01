resource "yandex_compute_instance" "default" {
  name = var.instance_name
  zone = var.zone
  platform_id = var.platform_id

  
  resources {
    core_fraction = 100
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
 #     size_gb = var.disk_size_gb
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    user-data = var.user_data
  }
}
