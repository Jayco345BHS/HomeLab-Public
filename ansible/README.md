# Ansible Overview

This directory contains the Ansible configuration used to provision and maintain the homelab VMs. The playbooks here handle three main jobs:

- applying baseline OS configuration to all managed hosts
- installing and configuring Docker where needed
- enabling NVIDIA support on the Plex host

It is organized around a standard Ansible layout: one config file, one inventory, a small set of playbooks, and three reusable roles.

---

## Folder Structure

```text
ansible/
├── ansible.cfg
├── inventory/
│   ├── homelab.ini
│   └── host_vars/
│       ├── docker-1.yml
│       └── plex-1.yml
├── playbooks/
│   ├── docker-update.yml
│   ├── provision.yml
│   └── update.yml
└── roles/
    ├── common/
    │   ├── defaults/
    │   │   └── main.yml
    │   ├── handlers/
    │   │   └── main.yml
    │   └── tasks/
    │       └── main.yml
    ├── docker_host/
    │   ├── defaults/
    │   │   └── main.yml
    │   ├── handlers/
    │   │   └── main.yml
    │   └── tasks/
    │       └── main.yml
    └── plex_gpu/
        ├── defaults/
        │   └── main.yml
        ├── handlers/
        │   └── main.yml
        └── tasks/
            └── main.yml
```

---

## Top-Level Files

### ansible.cfg

Primary Ansible configuration for this repo.

- sets the default inventory to `inventory/homelab.ini`
- sets `roles_path = roles` so the local roles resolve without extra flags
- uses `github` as the default SSH user
- disables host key checking and retry file generation
- enables automatic Python interpreter discovery
- configures SSH connection reuse with ControlMaster and ControlPersist

This file is what lets the playbooks run with short commands like `ansible-playbook playbooks/provision.yml` from inside this directory.

---

## Inventory

### inventory/homelab.ini

The main static inventory file for the lab.

It defines four hosts:

- `dns-1` at `192.168.1.11` with VMID `100`
- `docker-1` at `192.168.1.12` with VMID `101`
- `plex-1` at `192.168.1.13` with VMID `103`
- `gameserver-1` at `192.168.1.14` with VMID `104`

It also defines the following groups:

- `homelab`: every managed host
- `dns_servers`: currently only `dns-1`
- `docker_hosts`: hosts that should have Docker installed
- `plex_servers`: currently only `plex-1`
- `game_servers`: currently only `gameserver-1`

The `[homelab:vars]` section applies shared connection settings across all hosts, including `ansible_user=github`, privilege escalation with `sudo`, and relaxed SSH host key behavior.

### inventory/host_vars/docker-1.yml

Host-specific variables for `docker-1`.

- defines an SMB mount for `/mnt/media`
- points the mount at the TrueNAS host on `192.168.1.15`
- sets CIFS mount options so the share is writable by UID/GID `1000`
- uses `x-systemd.automount` and network-online options so mount recovery is resilient after host reboots

These variables are consumed by the `common` role when it creates mount points and mounts the shares.

### inventory/host_vars/plex-1.yml

Host-specific variables for `plex-1`.

- overrides the default NVIDIA driver version to `565`
- replaces the default driver package list with the matching headless/server packages
- defines an SMB mount for `/mnt/media` from the TrueNAS host

This file lets the Plex VM diverge from the generic GPU defaults without changing the shared role.

---

## Playbooks

### playbooks/provision.yml

Main provisioning playbook.

It runs three plays in order:

1. applies the `common` role to every host in `homelab`
2. applies the `docker_host` role to every host in `docker_hosts`
3. applies the `plex_gpu` role only to `plex-1`

This is the playbook to run when building or rebuilding the lab from a clean Ubuntu base.

### playbooks/docker-update.yml

Deploys Docker Compose stacks to hosts that run Docker workloads.

What it does:

- creates `/opt/docker` on each Docker host
- creates per-stack directories under `/opt/docker`
- copies stack files from the repo into those directories
- fixes ownership for the Seerr config directory
- runs `docker compose up -d --pull always --remove-orphans` in each active stack directory
- if a stack fails with `no space left on device`, prunes unused Docker images on that host and retries only the affected stacks once
- if no-space persists after retry, runs a no-pull reconcile so existing containers remain running
- fails immediately for non-space Docker errors, or if the no-pull fallback fails

Current host-to-stack mapping inside this playbook:

- `dns-1`: no stacks
- `docker-1`: `arrstack`, `yubal`, `homepage`, `termix`
- `plex-1`: `plex`, `immich`
- `gameserver-1`: no stacks

This playbook is for syncing Compose definitions after editing the Docker stack files in the repo.

### playbooks/update.yml

Simple package maintenance playbook for all hosts.

It performs:

- `apt update`
- distribution package upgrades
- `apt autoremove`

Each task is skipped for hosts in a `storage_servers` group. That group does not currently exist in `inventory/homelab.ini`, but the condition leaves room for excluding appliances such as TrueNAS from normal apt-based maintenance.

---

## Roles

### roles/common

Baseline role applied to every managed VM.

#### roles/common/defaults/main.yml

Default variables for the `common` role.

- `common_enable_system_upgrade`: whether to run dist-upgrade during provisioning
- `common_base_packages`: base tools installed on all hosts, including `cifs-utils`, `git`, `qemu-guest-agent`, `python3-pip`, and `python3-passlib`
- `common_extra_packages`: extension point for extra host packages
- `common_enable_password_auth`: whether SSH password auth should be enabled
- `common_alex_password_hash`: stored default for the `alex` user, though the task file currently pulls the password hash from the `ALEX_PASSWORD_HASH` environment variable instead

#### roles/common/tasks/main.yml

Implements the baseline host configuration.

It does the following:

- removes stale NVIDIA apt source files if present
- refreshes apt metadata
- optionally upgrades packages
- installs the base package set
- creates the `alex` sudo user
- ensures `qemu-guest-agent` is enabled when installed
- removes restrictive cloud-init SSH config snippets
- enables SSH password authentication
- creates any SMB mount point directories defined in host vars
- mounts SMB shares persistently using `ansible.posix.mount`

Several apt-related tasks are skipped for hosts in `storage_servers`, which is a safeguard for non-Ubuntu storage appliances.

#### roles/common/handlers/main.yml

Contains one handler:

- `Reload SSH`: reloads the SSH service after SSH config changes

### roles/docker_host

Role for installing and enabling Docker Engine on Linux hosts.

#### roles/docker_host/defaults/main.yml

Default variables for Docker hosts.

- `docker_users`: users that should be added to the `docker` group, currently `github` and `alex`
- `docker_package_state`: desired package state, default `present`
- `docker_service_state`: desired service state, default `started`
- `docker_service_enabled`: whether Docker should start on boot

#### roles/docker_host/tasks/main.yml

Installs Docker from Docker's official apt repository.

It does the following:

- installs prerequisite apt packages
- determines whether the host should use the `amd64` or `arm64` Docker repository
- creates `/etc/apt/keyrings`
- downloads Docker's GPG key
- adds the Docker apt repository for the current Ubuntu release
- installs Docker Engine, CLI, containerd, Buildx, and Compose plugin
- ensures the `docker` group exists
- adds the configured local users to the `docker` group
- ensures the Docker service is started and enabled

#### roles/docker_host/handlers/main.yml

Contains one handler:

- `Restart Docker`: restarts the Docker service when package or config changes require it

### roles/plex_gpu

Specialized role for enabling NVIDIA drivers and Docker GPU runtime support on the Plex VM.

#### roles/plex_gpu/defaults/main.yml

Default GPU-related variables.

- `nvidia_driver_version`: default driver version, `535`
- `nvidia_driver_packages`: package list derived from the configured version
- `nvidia_repo_arch_map`: maps system architecture to NVIDIA repo architecture names
- `nvidia_distro_map`: maps OS release names to the NVIDIA-supported distro labels
- `plex_gpu_reboot_after_driver`: controls whether Ansible should reboot automatically after driver install

Host vars for `plex-1` override these defaults to use the `565` server/headless driver packages.

#### roles/plex_gpu/tasks/main.yml

Configures NVIDIA support for both the host OS and Docker.

It does the following:

- derives the correct NVIDIA repo architecture and distribution label from gathered facts
- installs build dependencies and kernel headers
- installs the configured NVIDIA driver packages
- ensures the NVIDIA keyring directory exists
- downloads and dearmors the NVIDIA container toolkit GPG key
- removes stale NVIDIA apt source files
- writes the NVIDIA container toolkit apt repo file
- installs `nvidia-container-toolkit`
- runs `nvidia-ctk runtime configure --runtime=docker --set-as-default`
- writes a marker file so the Docker runtime configuration is only applied once

This role is what makes GPU-accelerated containers like Plex and Immich work correctly on `plex-1`.

#### roles/plex_gpu/handlers/main.yml

Contains two handlers:

- `Restart Docker`: restarts Docker after runtime/toolkit changes
- `Reboot for NVIDIA driver`: reboots the host when `plex_gpu_reboot_after_driver` is enabled

---

## How The Pieces Fit Together

Typical flow:

1. `provision.yml` prepares the OS, installs Docker where needed, and configures the Plex GPU host.
2. Host-specific SMB mounts from `inventory/host_vars` are applied by the `common` role.
3. `docker-update.yml` copies Compose projects from the repo to the Docker hosts and redeploys them.
4. `update.yml` handles ongoing apt maintenance for Ubuntu-based guests.

In practice, the Ansible directory is the bridge between the infrastructure defined elsewhere in the repo and the actual running VM state.

---

## Common Commands

Run these from the `ansible/` directory.

```bash
ansible-playbook playbooks/provision.yml
ansible-playbook playbooks/docker-update.yml
ansible-playbook playbooks/update.yml
ansible-playbook playbooks/provision.yml --tags smb_mounts
```

Useful ad-hoc checks:

```bash
ansible all -m ping
ansible docker_hosts -b -m shell -a "docker ps"
ansible plex-1 -b -m shell -a "nvidia-smi"
```