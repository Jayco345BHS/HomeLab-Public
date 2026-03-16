locals {
  vm_definitions = {
    "dns-1" = {
      hostname    = "dns-1"
      vmid        = 100
      ip          = "192.168.1.11"
      cores       = 2
      memory      = 2048
      disk_gb     = 32
      description = "Pi-hole DNS resolver"
      tags        = ["dns", "pihole"]
    }

    "docker-1" = {
      hostname    = "docker-1"
      vmid        = 101
      ip          = "192.168.1.12"
      cores       = 4
      memory      = 16384
      disk_gb     = 50
      description = "Primary Docker host for automation stacks"
      tags        = ["docker", "apps"]
    }

    "plex-1" = {
      hostname    = "plex-1"
      vmid        = 103
      ip          = "192.168.1.13"
      cores       = 4
      memory      = 8192
      disk_gb     = 40
      description = "Plex media server with NVIDIA GPU passthrough"
      tags        = ["plex", "gpu", "media"]
    }

    "gameserver-1" = {
      hostname    = "gameserver-1"
      vmid        = 104
      ip          = "192.168.1.14"
      cores       = 4
      memory      = 16384
      disk_gb     = 50
      description = "Game server workloads"
      tags        = ["games", "docker"]
    }
  }

  # TrueNAS VM definition (separate from cloud-init VMs)
  truenas_vm = {
    hostname    = "nas-1"
    vmid        = 102
    ip          = "192.168.1.15"
    cores       = 4
    memory      = 16384  # 16GB minimum recommended for TrueNAS
    disk_gb     = 32     # Boot drive (OS only)
    description = "TrueNAS Scale storage server with HBA passthrough"
    tags        = ["storage", "truenas", "hba"]
  }
}
