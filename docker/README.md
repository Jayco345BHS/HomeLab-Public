# Docker Stacks Overview

This directory contains the Docker Compose projects used across the homelab. Each subfolder is a self-contained stack with its own `docker-compose.yml` and, where needed, local configuration files such as `.env`, widget definitions, or hardware-acceleration overrides.

At a high level, this folder serves two purposes:

- it acts as the source of truth for containerized services tracked in the repo
- it gives Ansible a predictable set of stack directories to copy onto the Docker-capable VMs

The stacks are split by function rather than by host. Deployment targeting is handled separately by the Ansible playbook.

---

## Folder Structure

```text
docker/
├── arrstack/
├── authentik/
├── code-server/
├── gitea/
├── homepage/
├── immich/
├── keepalived/
├── nebula-sync/
├── nextcloud/
├── pi-hole/
├── plex/
├── termix/
├── traefik/
├── upsnap/
└── yubal/
```

Most stack directories follow the same pattern:

- `docker-compose.yml`: main Compose definition
- `.env`: stack-specific environment variables when required
- extra YAML files: service-specific config fragments or application config

---

## How This Folder Is Used

The Docker stacks in this directory are not all deployed everywhere.

Current Ansible-driven deployment targets:

- `docker-1`: `arrstack`, `homepage`, `termix`, `yubal`
- `plex-1`: `plex`, `immich`
- `dns-1`: no Compose stacks currently synced by the Ansible playbook
- `gameserver-1`: no Compose stacks currently synced by the Ansible playbook

Other stack folders are still tracked here even if they are not currently part of the automatic deployment flow. That keeps the repo ready for future rollout, testing, or manual deployment.

---

## Stack Summary

### arrstack

Primary media automation stack.

- includes the core *arr workflow such as Sonarr, Radarr, Lidarr, and Prowlarr
- includes qBittorrent routed through VPN
- includes Seerr for media requests and Tautulli for Plex analytics
- includes supporting files like `.env` and the OpenVPN profile

This is the main automation stack for media acquisition and organization.

### authentik

Self-hosted identity and access management stack.

- runs Authentik with PostgreSQL
- uses an `.env` file for secrets and database settings
- intended for SSO, identity brokering, and access control across internal apps

### code-server

Browser-based VS Code environment.

- provides remote code editing in a web UI
- stores persistent editor/workspace state under `./config`
- uses password-based auth placeholders by default for first-time setup

This is useful for editing infra files from any device without a local IDE.

### gitea

Self-hosted Git forge stack.

- runs Gitea with persistent data in `./data`
- exposes web UI and Git-over-SSH ports
- defaults to SQLite for simple single-node deployment

This is a lightweight option for internal Git hosting and project management.

### homepage

Dashboard and observability stack.

- provides the main landing page for homelab services
- includes service definitions, widgets, and Proxmox integration config
- stores most of its behavior in application YAML files rather than environment variables

This is the primary service portal documented elsewhere in the repo.

### immich

Photo and video backup platform.

- includes the main Immich app, database, Redis-compatible cache, and machine-learning services
- uses `.env` for storage and database settings
- includes hardware acceleration config files for GPU-backed workloads

This stack is designed to take advantage of the Plex host's GPU support.

### keepalived

High-availability networking helper.

- provides VRRP-based failover behavior using host networking and elevated network capabilities
- uses `.env` for VIP and interface settings

This is part of the repo's HA and network resilience experiments.

### nebula-sync

Pi-hole synchronization utility.

- syncs settings and lists between a primary Pi-hole and replicas
- configured through `.env`

This is intended to support multi-node DNS setups rather than standalone DNS.

### nextcloud

Personal cloud and file sync stack.

- tracks a Nextcloud AIO deployment
- bundles the main AIO container definition in a single Compose file
- is repo-managed even if not currently part of the default Ansible deployment set

### pi-hole

DNS and ad-blocking stack.

- runs Pi-hole with host networking
- uses `.env` for passwords and port overrides
- exposes DNS plus web admin access

This stack is the basis for local DNS in the homelab.

### plex

GPU-enabled Plex media server stack.

- runs Plex in host network mode
- requests NVIDIA GPU access through Docker
- mounts the shared media library from TrueNAS-backed storage

This stack is intentionally narrow and focused on the media server itself.

### termix

Browser-accessible terminal utility.

- lightweight Compose stack with persistent data volume
- intended for quick shell access and admin convenience

### traefik

Reverse proxy and ingress stack.

- runs Traefik with Docker provider integration
- exposes a dashboard and a sample `whoami` service
- defines its own `proxy` network

This is the foundation for routing self-hosted services behind a shared entrypoint.

### upsnap

Wake-on-LAN and device management utility.

- runs in host networking mode
- stores application data locally in the stack directory

This is useful for powering on or monitoring devices that do not need to run all the time.

### yubal

Music ingestion and library helper.

- uses the shared music library mount
- stores Beets, yt-dlp, and app config inside the stack directory
- focuses on automated music acquisition and metadata workflow

This complements the broader media stack rather than replacing Lidarr.

---

## Configuration Patterns

There are a few patterns repeated across this folder:

- stacks that need secrets or host-specific values usually keep them in a local `.env`
- stateful services usually mount local config or data directories next to the Compose file
- infrastructure-facing services often use `network_mode: host` when low-level network access is required
- GPU-aware services use dedicated Compose fragments or Docker device/runtime configuration instead of embedding everything in one file

Because these stacks target different hosts and responsibilities, they are intentionally kept separate instead of being merged into a single monolithic Compose project.

---

## Working With The Stacks

Typical local workflow from this directory:

```bash
cd docker/<stack-name>
docker compose pull
docker compose up -d
docker compose logs -f
```

Repo-driven deployment flow:

```bash
cd ansible
ansible-playbook playbooks/docker-update.yml
```

That playbook copies the selected stack directories to `/opt/docker/<stack-name>` on each target VM and then runs `docker compose up -d --pull always --remove-orphans` there.

---

## Notes

- This directory is the high-level source of truth for containerized homelab services.
- Not every tracked stack is currently auto-deployed, but each one is kept here so it can be versioned and reused.
- Infrastructure coupling is intentional: some stacks depend on TrueNAS-backed mounts, GPU runtime support, or host networking on specific VMs.