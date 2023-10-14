module "vm-for-each" {
  source         = "./instance"
  cores          = local.cores[each.key]
  memory         = local.memory[each.key]
  boot_disk_size = local.boot_disk_size[each.key]
  boot_disk_type = "network-hdd"
  for_each       = toset(["master", "node-1", "node-2", "teamcity-server", "teamcity-agent"])
  instance_name  = each.key
  image_family   = local.image_family[each.key]
  instance_zone  = local.ipv4_zones[each.key]
  subnet_id      = local.ipv4_subnets[each.key]
  ipv4_internal  = local.ipv4_internals[each.key]
  nat            = local.ipv4_nats[each.key]
  core_fraction  = local.core_fraction[each.key]
}

locals {

  cores = {
    master          = 4
    node-1          = 2
    node-2          = 2
    teamcity-server = 4
    teamcity-agent  = 2
  }

  memory = {
    master          = 4
    node-1          = 2
    node-2          = 2
    teamcity-server = 8
    teamcity-agent  = 2
  }

  boot_disk_size = {
    master          = 50
    node-1          = 50
    node-2          = 50
    teamcity-server = 50
    teamcity-agent  = 50
  }

  image_family = {
    master          = "ubuntu-2204-lts"
    node-1          = "ubuntu-2204-lts"
    node-2          = "ubuntu-2204-lts"
    teamcity-server = "container-optimized-image"
    teamcity-agent  = "container-optimized-image"
  }

  ipv4_zones = {
    master          = var.yandex-cloud-zone-1
    node-1          = var.yandex-cloud-zone-2
    node-2          = var.yandex-cloud-zone-3
    teamcity-server = var.yandex-cloud-zone-1
    teamcity-agent  = var.yandex-cloud-zone-1
  }

  ipv4_subnets = {
    master          = yandex_vpc_subnet.vpc-subnet-private-1.id
    node-1          = yandex_vpc_subnet.vpc-subnet-private-2.id
    node-2          = yandex_vpc_subnet.vpc-subnet-private-3.id
    teamcity-server = yandex_vpc_subnet.vpc-subnet-private-1.id
    teamcity-agent  = yandex_vpc_subnet.vpc-subnet-private-1.id
  }

  ipv4_internals = {
    master          = "10.10.10.1"
    node-1          = "10.20.20.1"
    node-2          = "10.30.30.1"
    teamcity-server = "10.10.10.10"
    teamcity-agent  = "10.10.10.20"
  }

  ipv4_nats = {
    master          = true
    node-1          = true
    node-2          = true
    teamcity-server = true
    teamcity-agent  = true
  }

  core_fraction = {
    master          = 20
    node-1          = 20
    node-2          = 20
    teamcity-server = 100
    teamcity-agent  = 20
  }
}
