# TrueNAS VM Deployment Guide

This guide walks you through deploying a TrueNAS Scale VM with HBA/disk passthrough on Proxmox using Terraform.

## Prerequisites

### 1. HBA Controller (Recommended)
- **Model**: LSI 9207-8i or LSI 9211-8i (flashed to IT mode)
- **Why**: Proper IOMMU isolation, better SMART support, direct disk access
- **Cost**: ~$50-100 used on eBay

### 2. Check IOMMU Groups (Current Setup)
Before buying an HBA, verify your SATA controller's IOMMU grouping issue:

```bash
# SSH into your Proxmox host
ssh root@192.168.1.10

# Check IOMMU groups
for d in /sys/kernel/iommu_groups/*/devices/*; do 
    n=${d#*/iommu_groups/*}; n=${n%%/*}
    printf 'IOMMU Group %s ' "$n"
    lspci -nns "${d##*/}"
done | grep -i sata
```

If your SATA controller is in the same group as other devices (USB, network, etc.), you **need an HBA**.

### 3. Enable IOMMU in Proxmox

Edit GRUB configuration:
```bash
nano /etc/default/grub
```

For Intel CPUs:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
```

For AMD CPUs:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt"
```

Update GRUB and reboot:
```bash
update-grub
reboot
```

Verify IOMMU is enabled:
```bash
dmesg | grep -e DMAR -e IOMMU
```

### 4. Load VFIO Modules

Edit modules file:
```bash
nano /etc/modules
```

Add:
```
vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd
```

Update initramfs and reboot:
```bash
update-initramfs -u -k all
reboot
```

## HBA Setup (After Installing Hardware)

### Find Your HBA's PCI Address
```bash
lspci -nn | grep -i lsi
# Example output: 03:00.0 SCSI storage controller [0100]: LSI Logic / Symbios Logic SAS2308 [1000:0087]
```

The PCI address in this example is `0000:03:00.0` (add the domain prefix `0000:`).

### Create Proxmox Resource Mapping (Recommended Method)

1. **Via Proxmox Web UI**:
   - Go to **Datacenter** > **Resource Mappings**
   - Click **Add** > **PCI Device**
   - Name: `hba-controller`
   - Select your HBA from the list
   - Click **Create**

2. **Via CLI** (alternative):
```bash
pvesh create /cluster/mapping/pci --id hba-controller --map node=proxmox-node,path=0000:03:00.0
```

### Verify Disk Detection
```bash
# List all disks by ID
ls -la /dev/disk/by-id/ | grep ata

# Check SMART capability
smartctl -i /dev/sda
smartctl -i /dev/sdb
# ... repeat for all drives
```

## TrueNAS ISO Upload

### Download TrueNAS Scale
```bash
# From Proxmox host
cd /var/lib/vz/template/iso
wget https://download.truenas.com/TrueNAS-SCALE-Dragonfish/24.10.0/TrueNAS-SCALE-24.10.0.iso
```

Or upload via Proxmox UI: **Datacenter** > **local** > **ISO Images** > **Upload**

### Update Terraform Variable
In `terraform.tfvars`, set the ISO path:
```hcl
truenas_iso_file = "local:iso/TrueNAS-SCALE-24.10.0.iso"
```

## Deployment Configuration

### HBA Passthrough (Resource Mapping Only)
This passes the entire HBA controller to TrueNAS, giving it direct access to all connected drives.

**terraform.tfvars**:
```hcl
enable_truenas = true
truenas_hba_mapping = "hba-controller"  # Resource mapping name
```

## Terraform Deployment

### 1. Initialize and Validate
```bash
cd terraform/proxmox
terraform init
terraform validate
terraform plan
```

### 2. Deploy
```bash
terraform apply
```

### 3. Install TrueNAS
1. Open Proxmox UI: https://192.168.1.10:8006
2. Navigate to VM 104 (truenas)
3. Start the VM
4. Open **Console**
5. Follow TrueNAS installation wizard:
   - Choose the **boot disk** (32GB virtual disk - scsi0)
   - **DO NOT** select your 8TB drives during installation
   - Create admin password
   - Reboot after installation

### 4. Post-Installation
After TrueNAS boots:

1. Access TrueNAS web UI: https://192.168.1.15
2. Login with admin credentials
3. Navigate to **Storage** > **Disks**
4. Verify all 4x 8TB drives are visible with SMART data
5. Create storage pool (ZFS RAID-Z1 or RAID-Z2 recommended)

### 5. Enable QEMU Guest Agent (Optional)
```bash
# In TrueNAS Scale shell
apt update
apt install qemu-guest-agent
systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent
```

Then in `terraform.tfvars`, you can manually set agent to enabled (or remove from lifecycle ignore_changes).

## Troubleshooting

### HBA Not Visible in VM
```bash
# Check if PCI device is bound to vfio-pci
lspci -nnk | grep -A3 "03:00.0"

# Should show: Kernel driver in use: vfio-pci
```

### Disks Not Showing in TrueNAS
1. Verify HBA passthrough in VM config:
   ```bash
   qm config 104
   ```
   Should show: `hostpci0: ...`

2. Check dmesg in TrueNAS:
   ```bash
   dmesg | grep -i scsi
   ```

3. Verify drives are connected to HBA, not motherboard SATA

### IOMMU Group Issues
If HBA shares IOMMU group with other devices, you may need to:
- Enable ACS Override (risky, not recommended for production)
- Use a different PCIe slot
- Get a different HBA that has better isolation

## Recommended HBA Settings

For LSI 9211-8i / 9207-8i:
- **Mode**: IT (Initiator Target) mode, NOT IR (RAID) mode
- **Firmware**: Flash to latest P20 IT firmware
- **Boot ROM**: Disabled (not needed for data drives)

## Network Configuration

The VM is configured with:
- IP: `192.168.1.15`
- Gateway: `192.168.1.1`
- DNS: `192.168.1.11, 1.1.1.1`

These are set via manual configuration post-installation (TrueNAS doesn't use cloud-init).

## Performance Tuning

Consider adding to `locals.tf` for production:
```hcl
cores  = 6   # More cores for ZFS scrubs
memory = 32768  # 32GB - ZFS loves RAM (1GB per TB rule of thumb)
```

For best performance, ensure:
- CPU type is set to `host` ✅ (already configured)
- Memory ballooning is disabled ✅ (already configured)
- iothread is enabled on boot disk ✅ (already configured)
- PCIe passthrough is enabled ✅ (already configured)

## Additional Resources

- [TrueNAS Documentation](https://www.truenas.com/docs/)
- [Proxmox PCIe Passthrough](https://pve.proxmox.com/wiki/PCI_Passthrough)
- [LSI HBA Guide](https://forums.servethehome.com/index.php?threads/lsi-raid-controller-and-hba-complete-listing-plus-oem-models.599/)
