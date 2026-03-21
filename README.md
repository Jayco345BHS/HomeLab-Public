# 🏠 My Home Lab

Welcome to my home lab repository!  
This project documents my journey building, configuring, and expanding a Proxmox-based home lab built around dedicated VMs, Docker workloads, and a TrueNAS-backed storage layer. While Plex is still a major focus, the lab now also covers photo backup, DNS, dashboards, automation, and game server hosting.

---

## 📜 Backstory

I built this machine with the intention of running a dedicated home lab from the start… but for its first year, it lived a different life — as my secondary gaming PC.  
The reason? I couldn’t decide on the perfect OS for my server until I finally committed to **Proxmox**.

Some of the hardware was repurposed from my old gaming rig — the GPU, PSU, and case — while the rest was chosen to be **cost-effective** but still powerful enough to run multiple VMs with ease.

---

## 🎯 Primary Goals

- **Plex Media Server** with NVIDIA hardware transcoding  
- **TrueNAS Scale** for centralized storage, SMB shares, and future pool growth  
- **Automated media management** with Sonarr, Radarr, Lidarr, Prowlarr, Seerr, and qBittorrent  
- **Dashboards and service UX** with Homepage and other self-hosted frontends  
- **Networking and DNS** with Pi-hole, VPN routing, and high-availability experiments  
- **Repeatable infrastructure** using Terraform and Ansible instead of manual rebuilds  
- Always testing **new software stacks** and lab concepts

---

## 🗄 Storage Setup

The old **QNAP NAS** is retired. Storage now lives on a dedicated **TrueNAS Scale** VM with HBA passthrough, giving the lab direct access to the disks and a cleaner path for pool management, SMART visibility, and future expansion.  
TrueNAS currently uses an **LSI 9207-8i HBA** with **4× 8 TB Seagate IronWolf 7200 RPM** drives for bulk storage. It now backs the SMB shares used by Plex, downloads, music, and personal data across the environment. The Terraform side of the repo includes a dedicated TrueNAS VM definition, and the Proxmox-specific setup notes live in `terraform/proxmox/TRUENAS-SETUP.md`.

---

## 🖥 Hardware Specs

| Component | Model |
|-----------|-------|
| **OS** | Proxmox |
| **CPU** | AMD Ryzen 7 5800X 3.8 GHz 8-Core |
| **Cooler** | Cooler Master Hyper 212 Black Edition |
| **Motherboard** | Gigabyte B550 AORUS ELITE AX V2 ATX AM4 |
| **RAM** | 2× Kingston FURY Beast RGB 32 GB (DDR4-3600 CL18) |
| **Storage** | WD Blue SN580 500 GB PCIe 4.0 NVMe SSD |
| **HBA** | LSI 9207-8i |
| **TrueNAS Data Drives** | 4× 8 TB Seagate IronWolf 7200 RPM |
| **GPU** | EVGA GTX 1080 FTW GAMING ACX 3.0 8 GB |
| **Case** | Fractal Design Define C ATX Mid Tower |
| **PSU** | EVGA SuperNOVA 750 G2 (750 W, 80+ Gold, Fully Modular) |

---

## 📦 Current VM & Container Workloads

- **Storage** – `nas-1` running TrueNAS Scale with HBA passthrough and SMB shares  
- **Media** – Plex with GPU acceleration, Sonarr, Radarr, Lidarr, Prowlarr, qBittorrent, Seerr, Tautulli, and Yubal  
- **Photos & Files** – Immich for photo/video backup and a tracked Nextcloud stack for personal cloud services  
- **Dashboards** – Homepage as the primary service portal and status dashboard  
- **Networking** – Pi-hole for DNS, Gluetun for VPN-routed download traffic, plus repo-tracked Keepalived and Nebula Sync for HA work  
- **Access & Utilities** – Authentik, Traefik, Termix, Upsnap, and other supporting self-hosted services tracked in Compose  
- **Game Hosting** – AMP on Ubuntu 24.04 for Minecraft and other game server workloads

---

## 🔮 Future Plans

- Expand TrueNAS capacity, pool layout, and backup strategy
- Bring more auxiliary Compose stacks under the same automated deployment flow
- Keep refining DNS and service high-availability patterns
- Experiment with Kubernetes or Docker Swarm when the current Docker layout starts to feel limiting
- Expand into more advanced home automation integrations

---

## ⚙️ Automated Rebuilds

Terraform now owns VM creation on Proxmox while Ansible configures each guest and syncs the active Docker stacks. Most guests target Ubuntu 24.04; TrueNAS is handled separately as an ISO-based VM with manual post-install networking.

### Terraform (Proxmox)

1. Make sure Proxmox hosts an Ubuntu 24.04 cloud-init template that matches `var.template_name` (defaults to `ubuntu-24.04-cloudinit`).
2. Create an API token with sufficient rights on the `192.168.1.10` host, then fill in `terraform/proxmox/terraform.tfvars` with secrets, network info, and TrueNAS settings.
3. Deploy or rebuild: `cd terraform/proxmox && terraform init && terraform plan -out plan.tfplan && terraform apply plan.tfplan`.
4. For TrueNAS, follow the ISO install and HBA passthrough notes in `terraform/proxmox/TRUENAS-SETUP.md` after Terraform creates the VM shell.

| VM | vCPU | RAM | Disk | IP | Notes |
| --- | --- | --- | --- | --- | --- |
| DNS-1 | 2 | 2 GB | 32 GB | 192.168.1.11 | Pi-hole / DNS |
| Docker-1 | 4 | 16 GB | 50 GB | 192.168.1.12 | Primary Docker host |
| NAS-1 | 4 | 16 GB | 32 GB boot disk + passthrough storage | Manual post-install | TrueNAS Scale storage server |
| PLEX | 4 | 8 GB | 50 GB | 192.168.1.13 | GPU-enabled Plex server |
| Game Server | 4 | 16 GB | 50 GB | 192.168.1.14 | Game + lab workloads |

### Ansible provisioning

1. Adjust `ansible/inventory/homelab.ini` if IPs ever change (Terraform also prints a compatible block via the `ansible_inventory` output).
2. Bootstrap packages, Docker, and host-level dependencies: `cd ansible && ansible-playbook playbooks/provision.yml`.
3. Re-sync the active Compose projects after editing the `/docker` directory: `ansible-playbook playbooks/docker-update.yml`.
	The playbook now retries stack updates that fail with `no space left on device` by pruning unused Docker images on that host, then rerunning only the affected stacks.
	If a pull still cannot complete due to disk pressure, it reconciles the stack without pulling new images so currently running services stay online.

The `plex` host installs `nvidia-driver-535`, the NVIDIA Container Toolkit, and configures Docker to default to the NVIDIA runtime so Plex and Immich can use GPU acceleration immediately after a reboot. The Docker update playbook currently syncs the active `arrstack`, `homepage`, `termix`, `yubal`, `plex`, and `immich` stacks.

---

## 💡 Ideas & Suggestions

I’m always looking for new ways to push this home lab further.  
If you have suggestions, interesting services to try, or best practices for Proxmox and container orchestration — feel free to open an **Issue** or share them!

---

## 📷 Photos & Screenshots
*(Coming soon)*

---

**Last Updated:** March 2026
