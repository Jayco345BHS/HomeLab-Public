resource "proxmox_virtual_environment_vm" "vm" {
  for_each = local.vm_definitions

  name        = each.value.hostname
  vm_id       = each.value.vmid
  node_name   = var.pm_node
  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
    type  = var.vm_cpu_type  # Uses "host" for maximum performance
  }

  memory {
    dedicated = each.value.memory
    floating  = var.enable_memory_ballooning ? each.value.memory : 0
  }

  scsi_hardware = var.scsi_controller

  on_boot = true
  started = var.start_on_create

  pool_id = var.resource_pool != "" ? var.resource_pool : null

  description = each.value.description

  disk {
    datastore_id = var.os_storage_pool
    interface    = "scsi0"
    size         = each.value.disk_gb
  }

  network_device {
    bridge = var.vm_network_bridge
    model  = "virtio"
    firewall = true
  }

  # Machine and BIOS settings (inherited from template for most VMs)
  machine = "q35"  # Modern machine type for all VMs
  bios    = "ovmf" # UEFI boot (matches template)

  # PCI device passthrough for Plex VM (NVIDIA GPU)
  dynamic "hostpci" {
    for_each = each.value.hostname == "plex-1" ? [1] : []
    content {
      device  = "hostpci0"
      mapping = "nvidia-gpu"
      pcie    = true
      rombar  = true
    }
  }

  initialization {
    datastore_id = var.cloudinit_storage_pool
    ip_config {
      ipv4 {
        address = "${each.value.ip}/${var.subnet_cidr}"
        gateway = var.gateway
      }
    }
    dns {
      servers = var.dns_servers
      domain  = var.search_domain
    }
    user_account {
      username = var.cloud_init_user
      password = var.cloud_init_password
      keys     = var.ssh_public_keys
    }
  }

  tags = distinct(
    concat(
      var.default_tags,
      lookup(each.value, "tags", [])
    )
  )

}

# Separate resource for TrueNAS VM (ISO-based, not cloud-init)
resource "proxmox_virtual_environment_vm" "truenas" {
  count = var.enable_truenas ? 1 : 0

  name      = local.truenas_vm.hostname
  vm_id     = local.truenas_vm.vmid
  node_name = var.pm_node

  # Use q35 machine type for better PCIe passthrough support
  machine = "q35"
  bios    = "ovmf"  # UEFI required for modern storage controllers

  agent {
    enabled = false  # No guest agent until TrueNAS is installed
  }

  cpu {
    cores = local.truenas_vm.cores
    type  = "host"  # Use host CPU type for best performance
  }

  memory {
    dedicated = local.truenas_vm.memory
    floating  = 0  # Disable ballooning for storage server
  }

  scsi_hardware = var.scsi_controller

  on_boot = true
  started = false  # Don't auto-start until OS is installed

  pool_id = var.resource_pool != "" ? var.resource_pool : null

  description = local.truenas_vm.description

  # EFI disk (required for UEFI)
  efi_disk {
    datastore_id = var.os_storage_pool
    file_format  = "raw"
    type         = "4m"
  }

  # Boot disk (TrueNAS OS)
  disk {
    datastore_id = var.os_storage_pool
    interface    = "scsi0"
    size         = local.truenas_vm.disk_gb
    discard      = "on"
    ssd          = true
    iothread     = true
  }

  # CD-ROM for TrueNAS ISO installation
  cdrom {
    enabled   = true
    file_id   = var.truenas_iso_file
    interface = "ide3"
  }

  network_device {
    bridge   = var.vm_network_bridge
    model    = "virtio"
    firewall = true
  }

  # HBA Controller Passthrough (Resource Mapping)
  hostpci {
    device  = "hostpci0"
    mapping = var.truenas_hba_mapping
    pcie    = true
    rombar  = true
  }

  tags = distinct(
    concat(
      var.default_tags,
      local.truenas_vm.tags
    )
  )

  lifecycle {
    ignore_changes = [
      # Ignore changes to started state after initial creation
      started,
      # Ignore changes to agent after OS installation
      agent,
      # Ignore manual disk additions
      disk,
    ]
  }
}
