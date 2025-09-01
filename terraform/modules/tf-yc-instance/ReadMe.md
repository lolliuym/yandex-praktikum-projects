# Terraform module for creating a Yandex Compute Instance

This module creates a virtual machine in Yandex Cloud.

## Dependencies

*   Yandex Cloud provider

## Parameters

| Name            | Description                         | Type   | Default     |
| --------------- | ----------------------------------- | ------ | ----------- |
| instance_name   | Name of the virtual machine         | string | "std-ext-016-02-terraform"   |
| zone            | Availability zone                   | string | "ru-central1-a" |
| subnet_id       | Subnet ID                           | string |             |
| image_id        | Image ID                            | string |             |
| platform_id     | Platform ID                         | string | "standard-v1" |
| scheduling_policy| Scheduling Policy                    | string | "preemptible" |
| disk_size_gb    | Disk Size in GB                      | number | 20          |


## Outputs

| Name                | Description                       |
| ------------------- | --------------------------------- |
| instance_external_ip | External IP address of the instance |
