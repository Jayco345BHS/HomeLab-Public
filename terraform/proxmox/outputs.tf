output "vm_ips" {
  description = "Static IP assignments for the managed VMs"
  value = {
    for name, cfg in local.vm_definitions :
    name => cfg.ip
  }
}

output "ansible_inventory" {
  description = "Convenience block that can be copied into ansible/inventory/homelab.ini"
  value = join(
    "\n",
    concat(
      ["[homelab]"],
      [for name, cfg in local.vm_definitions : "${name} ansible_host=${cfg.ip}"],
      [""],
      ["[homelab:vars]"],
      [
        "ansible_user=${var.cloud_init_user}",
        "ansible_become=true",
        "ansible_become_method=sudo"
      ]
    )
  )
}
