# Terraform module for creating a Yandex VPC Network and Subnets

This module creates a VPC network and subnets in Yandex Cloud.

## Dependencies

*   Yandex Cloud provider

## Parameters

| Name            | Description                         | Type         | Default                       |
| --------------- | ----------------------------------- | ------------ | ----------------------------- |
| network_zones   | List of availability zones          | list(string) | `["ru-central1-a", "ru-central1-b", "ru-central1-d"]` |

## Outputs

| Name         | Description                     |
| ------------ | ------------------------------- |
| network_id   | ID of the VPC network           |
| subnet_ids   | Map of subnet IDs per zone     |
