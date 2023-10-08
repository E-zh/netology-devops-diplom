terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone      = var.yc-zone
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
}

#Folder
resource "yandex_resourcemanager_folder" "netology-folder" {
  name = var.yc-folder-name
}
