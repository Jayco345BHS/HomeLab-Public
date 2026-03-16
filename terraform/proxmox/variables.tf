variable "pm_api_url" {
  description = "Full Proxmox API URL e.g. https://192.168.1.10:8006/api2/json"
  type        = string
}

variable "pm_api_token_id" {
  description = "Proxmox API token id in the format user@realm!token"
  type        = string
}

variable "pm_api_token_secret" {
  description = "Secret associated with the Proxmox API token"
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Set to true to skip TLS verification for on-prem clusters"
  type        = bool
  default     = true
}

variable "pm_node" {
  description = "Proxmox node name that will host the VMs"
  type        = string
}

variable "resource_pool" {
  description = "Optional Proxmox resource pool name"
  type        = string
  default     = ""
}

variable "template_vm_id" {
  description = "VM ID of the Ubuntu 24.04 Server cloud-init template to clone"
  type        = number
  default     = 9000
}

variable "os_storage_pool" {
  description = "Storage pool for VM disks"
  type        = string
}

variable "cloudinit_storage_pool" {
  description = "Storage pool that stores the cloud-init ISO (typically local-lvm)"
  type        = string
}

variable "vm_network_bridge" {
  description = "Proxmox bridge the VMs should attach to"
  type        = string
  default     = "vmbr0"
}

variable "subnet_cidr" {
  description = "CIDR suffix for the management network"
  type        = number
  default     = 24
}

variable "gateway" {
  description = "Default gateway for the VMs"
  type        = string
}

variable "dns_servers" {
  description = "Optional list of DNS servers injected via cloud-init"
  type        = list(string)
  default     = []
}

variable "search_domain" {
  description = "Optional search domain for the VMs"
  type        = string
  default     = ""
}

variable "cloud_init_user" {
  description = "Initial administrator username configured via cloud-init"
  type        = string
  default     = "github"
}

variable "cloud_init_password" {
  description = "Password for the cloud-init user (leave empty when only using SSH keys)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssh_public_keys" {
  description = "List of SSH public keys that should have access to the VMs"
  type        = list(string)
  default     = []
}

variable "default_tags" {
  description = "Tags added to every VM"
  type        = list(string)
  default     = [
    "terraform",
    "homelab"
  ]
}

variable "vm_cpu_type" {
  description = "CPU type exposed to the guest"
  type        = string
  default     = "host"  # Maximum performance - matches template
}

variable "scsi_controller" {
  description = "SCSI controller type for the VM"
  type        = string
  default     = "virtio-scsi-single"
}

variable "enable_memory_ballooning" {
  description = "Toggle virtio ballooning. Set false when pinning exact memory"
  type        = bool
  default     = true
}

variable "start_on_create" {
  description = "Automatically power on the VM after Terraform creates it"
  type        = bool
  default     = true
}

# TrueNAS-specific variables
variable "enable_truenas" {
  description = "Whether to deploy the TrueNAS VM"
  type        = bool
  default     = false
}

variable "truenas_iso_file" {
  description = "Path to TrueNAS ISO file in Proxmox storage (e.g., local:iso/TrueNAS-SCALE-22.12.4.iso)"
  type        = string
  default     = "local:iso/TrueNAS-SCALE.iso"
}

variable "truenas_hba_mapping" {
  description = "Proxmox resource mapping name for the HBA controller (configure in Proxmox datacenter > Resource Mappings)"
  type        = string
  default     = "hba-controller"
}
