module "tf-yc-network" {
  source = "./modules/tf-yc-network"
  network_zones = var.network_zones
 }

module "tf-yc-instance" {
  source          = "./modules/tf-yc-instance"
  instance_name   = var.instance_name
  zone            = var.zone
  subnet_id       = module.tf-yc-network.subnet_ids[var.zone]  
  image_id        = var.image_id
  platform_id     = var.platform_id
  user_data       = file("${path.module}/cloud-init.yaml")
  disk_size_gb    = var.disk_size_gb
}

 