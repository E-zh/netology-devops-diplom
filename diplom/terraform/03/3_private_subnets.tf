resource "yandex_vpc_subnet" "vpc-subnet-private-1" {
  name           = "vpc-subnet-private-1"
  network_id     = yandex_vpc_network.vpc-network-private.id
  zone           = var.yandex-cloud-zone-1
  v4_cidr_blocks = [var.ipv4_cidr_private_subnet-1]
}

resource "yandex_vpc_subnet" "vpc-subnet-private-2" {
  name           = "vpc-subnet-private-2"
  network_id     = yandex_vpc_network.vpc-network-private.id
  zone           = var.yandex-cloud-zone-2
  v4_cidr_blocks = [var.ipv4_cidr_private_subnet-2]
}

resource "yandex_vpc_subnet" "vpc-subnet-private-3" {
  name           = "vpc-subnet-private-3"
  network_id     = yandex_vpc_network.vpc-network-private.id
  zone           = var.yandex-cloud-zone-3
  v4_cidr_blocks = [var.ipv4_cidr_private_subnet-3]
}
