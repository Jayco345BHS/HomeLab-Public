# Media Server, Game Hosting & Automation Stack Overview

This stack brings together tools for **media acquisition, organization, delivery, automation, and monitoring**, along with **UI dashboards**, **infrastructure utilities**, and **game server hosting**.  
Below is a breakdown of each application, categorized by purpose, with explanations of how they fit together and key differences between similar apps.

---

## 📑 Quick Links

- [📦 Infrastructure & Networking](#-infrastructure--networking)  
  - [Gluetun](#gluetun)  
  - [Pi-hole](#pi-hole)  
  - [Traefik](#traefik)  
  - [Keepalived](#keepalived)  
  - [Nebula Sync](#nebula-sync)  
  - [Authentik](#authentik)  
  - [Portainer](#portainer)  
  - [Watchtower](#watchtower)  
  - [Ansible](#ansible)  

- [🎬 Media Managers](#-media-managers)  
  - [Sonarr](#sonarr)  
  - [Radarr](#radarr)  
  - [Lidarr](#lidarr)  
  - [Bazarr](#bazarr)  
  - [Yubal](#yubal)  

- [🔍 Indexer Management](#-indexer-management)  
  - [Prowlarr](#prowlarr)  

- [⬇ Download Clients](#-download-clients)  
  - [qBittorrent](#qbittorrent)  
  - [Deluge](#deluge)  
  - [Transmission](#transmission)  
  - [NZBGet](#nzbget)  

- [📺 Media Request & Discovery](#-media-request--discovery)  
  - [Seerr](#seerr)  
  - [Overseerr](#overseerr)  
  - [Jellyseerr](#jellyseerr)  

- [📽 Media Servers](#-media-servers)  
  - [Plex](#plex)  
  - [Jellyfin](#jellyfin)  
  - [Tautulli](#tautulli)  

- [📸 Photos, Files & Personal Cloud](#-photos-files--personal-cloud)  
  - [Immich](#immich)  
  - [Nextcloud](#nextcloud)  

- [🖥 Dashboards & Homepages](#-dashboards--homepages)  
  - [Homepage](#homepage)  
  - [Homarr](#homarr)  
  - [Heimdall](#heimdall)  

- [🛠 Access & Utilities](#-access--utilities)  
  - [Code Server](#code-server)  
  - [Gitea](#gitea)  
  - [Termix](#termix)  
  - [Upsnap](#upsnap)  

- [🎮 Game Servers & Hosting](#-game-servers--hosting)  
  - [AMP (Application Management Panel)](#amp-application-management-panel)  

---

## 📦 Infrastructure & Networking

### **Gluetun**
A lightweight VPN client container for Docker that routes traffic from other containers (like qBittorrent, NZBGet, Deluge, Transmission) through a VPN provider.  
- **Purpose:** Privacy, security, and bypassing ISP restrictions.  
- **Integration:** Media download clients are networked through Gluetun to ensure all traffic is encrypted.

### **Pi-hole**
A network-wide DNS sinkhole and ad-blocking service.  
- **Purpose:** Provides local DNS resolution, ad blocking, and a central control point for DNS behavior across the lab.  
- **Integration:** Acts as core DNS infrastructure for the environment and pairs well with Nebula Sync and Keepalived for consistency and resiliency.

### **Traefik**
A modern reverse proxy and ingress router for self-hosted services.  
- **Purpose:** Publishes internal services behind consistent routing rules and a single front door.  
- **Integration:** Watches Docker labels, routes traffic to eligible containers, and can front dashboards or apps that should not be exposed directly.

### **Keepalived**
A high-availability failover service built around VRRP.  
- **Purpose:** Maintains a virtual IP that can move between nodes when a primary service becomes unavailable.  
- **Integration:** Useful for resilient access to network services such as DNS, reverse proxy endpoints, or other critical entry points.

### **Nebula Sync**
A synchronization utility for multiple Pi-hole instances.  
- **Purpose:** Replicates settings and lists between a primary Pi-hole and one or more replicas.  
- **Integration:** Keeps DNS blocklists and related configuration aligned across Pi-hole nodes so HA experiments stay operational.

### **Authentik**
An identity provider and SSO platform for self-hosted applications.  
- **Purpose:** Centralizes authentication, user management, and access policy enforcement.  
- **Integration:** Can sit in front of internal services to provide consistent login flows and stronger access control than app-by-app local accounts.

### **Portainer**
A Docker management UI to deploy, monitor, and manage containers without using CLI.  
- **Purpose:** Simplifies container lifecycle management.  
- **Integration:** Can manage this entire stack and other containers running on the host.

### **Watchtower**
An automatic container updater.  
- **Purpose:** Keeps Docker images up to date with minimal intervention.  
- **Integration:** Monitors running containers and updates them when new versions are available.

### **Ansible**
An open-source automation tool for provisioning and managing systems.  
- **Purpose:** Automates setup, configuration, and updates for servers and services.  
- **Integration:** Can deploy this whole stack with repeatable playbooks.

---

## 🎬 Media Managers

### **Sonarr**
Automates downloading and organizing TV shows.  
- **Purpose:** Monitors your TV library, finds missing episodes, and sends download requests to your chosen client.  
- **Integration:** Works with Prowlarr for indexers, sends downloads to qBittorrent/NZBGet/Deluge/Transmission.

### **Radarr**
Similar to Sonarr but for movies.  
- **Purpose:** Automates movie discovery, acquisition, and organization.  
- **Integration:** Works with Prowlarr and your download clients.

### **Lidarr**
Automates downloading and managing music libraries.  
- **Purpose:** Finds and organizes albums, singles, and artist discographies.  
- **Integration:** Uses Prowlarr for indexers, sends requests to download clients.

### **Bazarr**
Subtitle management automation tool for your media library.  
- **Purpose:** Automatically searches, downloads, and syncs subtitles for movies and TV shows in multiple languages.  
- **Integration:** Works alongside Sonarr and Radarr to provide subtitles for newly downloaded or existing media.  
- **Differences:** Unlike Sonarr/Radarr/Lidarr, it doesn’t handle the actual media download — only subtitle acquisition and syncing.

### **Yubal**
A music acquisition and library workflow tool built around scheduled downloads and metadata handling.  
- **Purpose:** Pulls music into the library, enriches it with metadata and lyrics, and supports audio processing options like replay gain.  
- **Integration:** Complements Lidarr by handling additional music ingestion workflows and writing directly into the shared music library.

---

## 🔍 Indexer Management

### **Prowlarr**
Centralized indexer management tool that integrates with Sonarr, Radarr, Lidarr, and other *arr apps.  
- **Purpose:** Unifies indexer configuration and API key management.  
- **Integration:** Syncs indexers to the other *arr apps automatically.

---

## ⬇ Download Clients

### **qBittorrent**
Popular torrent client with web UI and automation support.  
- **Purpose:** Handles torrent-based downloads for Sonarr/Radarr/Lidarr.  
- **Integration:** Can be routed through Gluetun for VPN protection.

### **Deluge**
Lightweight torrent client alternative to qBittorrent.  
- **Purpose:** Torrent downloading with plugin support.  
- **Differences:** Less resource usage than qBittorrent but fewer built-in features.  
- **Integration:** Can be routed through Gluetun.

### **Transmission**
Minimalist torrent client with low resource usage.  
- **Purpose:** Simple, stable torrenting.  
- **Differences:** Very lightweight but less feature-rich than qBittorrent or Deluge.  
- **Integration:** Works with *arr apps; can run through Gluetun.

### **NZBGet**
Usenet download client.  
- **Purpose:** Handles Usenet downloads faster and more efficiently than torrents in some cases.  
- **Differences:** Requires paid Usenet provider; typically faster and more reliable than torrents.  
- **Integration:** Works with *arr apps; can also be routed through Gluetun.

---

## 📺 Media Request & Discovery

### **Seerr**
A modern request management app for media libraries.  
- **Purpose:** Lets users browse and request content through a clean web UI without manually touching the *arr stack.  
- **Differences:** In this lab, Seerr is replacing both Overseerr and Jellyseerr as the new all-in-one request layer instead of splitting requests by Plex-versus-Jellyfin focus.  
- **Integration:** Connects to Sonarr and Radarr for fulfillment and is intended to become the single request frontend for the media workflow.

### **Overseerr**
A web-based request and discovery app for Plex/Jellyfin libraries.  
- **Purpose:** Lets users request new movies/TV shows, integrates with Plex for metadata and availability checks.  
- **Differences:** Overseerr is Plex-focused but can integrate with Jellyfin with limited features. In this repo it is older context rather than the preferred path forward.  
- **Integration:** Sends approved requests to Radarr/Sonarr for automation.

### **Jellyseerr**
A fork of Overseerr optimized for Jellyfin.  
- **Purpose:** Same as Overseerr but built with Jellyfin integration as the primary focus.  
- **Differences:** Jellyseerr supports Jellyfin’s APIs better, while Overseerr is better for Plex-first setups. In this lab it is being superseded by Seerr as a single consolidated request solution.  
- **Integration:** Sends approved requests to Radarr/Sonarr, pulls metadata from Jellyfin.

---

### 📊 Overseerr vs Jellyseerr Comparison

| Feature                          | Overseerr                                          | Jellyseerr                                        |
|-----------------------------------|----------------------------------------------------|---------------------------------------------------|
| **Primary Focus**                 | Plex integration                                   | Jellyfin integration                              |
| **Supports Plex**                  | ✅ Full support                                    | ⚠ Limited — primarily Jellyfin-focused            |
| **Supports Jellyfin**              | ⚠ Limited — fewer features compared to Plex        | ✅ Full support                                    |
| **Metadata Source**                | Plex API (and partially Jellyfin API)              | Jellyfin API (and partially Plex API)             |
| **UI/UX**                          | Modern, sleek, Plex-style interface                | Same base interface (fork of Overseerr)           |
| **Ease of Setup**                  | Easier for Plex users                              | Easier for Jellyfin users                         |
| **Notifications**                  | Supports Discord, Telegram, Slack, etc.            | Same notification integrations as Overseerr       |
| **Community Activity**             | Larger Plex-focused community                      | Growing Jellyfin-focused community                |
| **Best For**                       | Users running Plex as their main media server      | Users running Jellyfin as their main media server |

---

## 📽 Media Servers

### **Plex**
A proprietary media server platform for streaming personal libraries.  
- **Purpose:** Serves and transcodes movies, TV shows, and music to various devices.  
- **Strengths:** Large app ecosystem, strong metadata support, remote streaming via Plex account.  
- **Weaknesses:** Some features locked behind Plex Pass subscription.  
- **Integration:** Works seamlessly with Overseerr, Sonarr, Radarr, Lidarr, Bazarr.

### **Jellyfin**
An open-source alternative to Plex.  
- **Purpose:** Serves and transcodes media without subscriptions.  
- **Strengths:** 100% free, privacy-focused, highly customizable.  
- **Weaknesses:** Fewer official client apps and integrations compared to Plex.  
- **Integration:** Works best with Jellyseerr, Sonarr, Radarr, Lidarr, Bazarr.

### **Tautulli**
A monitoring and analytics companion for Plex.  
- **Purpose:** Tracks stream activity, user history, playback statistics, and server usage trends.  
- **Integration:** Sits alongside Plex to provide observability, reporting, and alerting that the base Plex UI does not expose as clearly.

---

### 📊 Plex vs Jellyfin Comparison

| Feature                          | Plex                                               | Jellyfin                                           |
|-----------------------------------|----------------------------------------------------|----------------------------------------------------|
| **License**                       | Proprietary (free tier + paid Plex Pass)           | Open-source (GNU GPLv2, fully free)                |
| **Cost**                          | Free with optional paid features                   | Completely free                                    |
| **Official Client Apps**          | Yes — available on most platforms                  | Limited — fewer official apps, community clients   |
| **Remote Access**                 | Built-in via Plex account                          | Manual setup via reverse proxy/VPN required        |
| **Metadata & Artwork**            | Built-in metadata agents, strong out-of-box support| Good metadata but requires more manual setup       |
| **Transcoding**                    | Hardware & software transcoding (Plex Pass unlocks advanced features) | Hardware & software transcoding (open-source, no paywall) |
| **Plugins & Extensions**          | Limited official plugin support                    | Wide range of community plugins                    |
| **Live TV & DVR**                  | Available (Plex Pass only)                         | Available (free)                                   |
| **Privacy**                        | Requires Plex account, metadata may be shared with Plex servers | Fully local control, no mandatory external accounts|
| **Ease of Setup**                  | Very user-friendly                                 | Requires more manual configuration                 |
| **Best For**                       | Users wanting ease of use, official apps, easy remote access | Users wanting full control, no subscriptions, open-source freedom |

---

## 📸 Photos, Files & Personal Cloud

### **Immich**
A self-hosted photo and video backup platform with modern mobile and web apps.  
- **Purpose:** Replaces cloud photo storage with automatic backup, timeline browsing, and search features.  
- **Integration:** Uses PostgreSQL, Redis/Valkey, and optional GPU acceleration for machine learning and transcoding, making it a good fit for the existing Plex GPU host.

### **Nextcloud**
A self-hosted personal cloud suite for files, syncing, and collaboration.  
- **Purpose:** Provides Dropbox-style file sync plus a broader ecosystem for notes, calendars, contacts, and collaboration features.  
- **Integration:** In this repo it is tracked as a Nextcloud AIO deployment, which packages the platform in a more guided all-in-one setup.

---

## 🖥 Dashboards & Homepages

### **Homepage**
Highly customizable modern dashboard for self-hosted services.  
- **Purpose:** Single page to access and monitor all your services.  
- **Differences:** Feature-rich, supports widgets and service integrations.  
- **Integration:** Can show container statuses, system metrics, and links to web UIs.

### **Homarr**
A drag-and-drop self-hosted dashboard for organizing service links and monitoring apps.  
- **Purpose:** Visual, widget-based service launcher.  
- **Differences:** Easier to customize visually than Homepage, but fewer built-in integrations.  
- **Integration:** Pulls data from running services for quick status checks.

### **Heimdall**
Lightweight application dashboard with category/grouping support.  
- **Purpose:** Quick-launch hub for all your web apps.  
- **Differences:** Simplest of the dashboards, focusing on organized links without heavy features.  
- **Integration:** Primarily used for organized link management.

---

## 🛠 Access & Utilities

### **Code Server**
A self-hosted browser-based VS Code environment.  
- **Purpose:** Provides remote development access to scripts, configs, and infrastructure files from any browser without needing a local editor installed.  
- **Integration:** Fits naturally into a homelab for quick admin edits, repo work, and remote troubleshooting when you do not want to start a full desktop session.

### **Gitea**
A lightweight self-hosted Git service for repositories, issues, and collaboration.  
- **Purpose:** Hosts Git repositories with a simpler and lighter footprint than larger forge platforms.  
- **Integration:** Works well with automation repos, homelab documentation, and service configs, and pairs nicely with Authentik or reverse proxies for controlled internal access.

### **Termix**
A browser-accessible terminal utility for quick shell access and lightweight admin workflows.  
- **Purpose:** Gives you an easy way to reach a terminal session without opening a full SSH client on every device.  
- **Integration:** Useful as a convenience tool alongside dashboards and infrastructure services when you need quick operational access.

### **Upsnap**
A wake-on-LAN and device availability dashboard.  
- **Purpose:** Lets you power on supported devices remotely and track whether they are reachable on the network.  
- **Integration:** Fits well in a homelab where desktops, servers, or appliances are not always running but still need to be brought online on demand.

---

## 🎮 Game Servers & Hosting

### **AMP (Application Management Panel)**
A powerful, web-based game server management panel for hosting and controlling game servers.  
- **Purpose:** Provides a unified interface for installing, updating, configuring, and monitoring game servers without manually editing config files.  
- **Features:**  
  - Supports a wide range of games (Minecraft, Valheim, CS:GO, ARK, and more).  
  - Web-based GUI for managing multiple instances.  
  - Scheduled backups and updates.  
  - Resource usage monitoring for CPU, RAM, and disk.  
  - A permissions system for allowing others to manage specific servers.  
- **Integration:**  
  - Can run alongside your media server stack on the same Proxmox host or a separate VM/LXC.  
  - Managed separately from the *arr media apps, but can be linked on dashboards like Homepage/Homarr/Heimdall for quick access.  
- **Differences:** Unlike Portainer, which manages Docker containers, AMP is specialized for game server lifecycle management.

---

## 🧩 How They Fit Together

1. **User Requests Media**  
   - Overseerr (for Plex) or Jellyseerr (for Jellyfin) is used to request movies, TV shows, or music.

2. **Media Managers Trigger Search**  
   - Sonarr/Radarr/Lidarr communicate with Prowlarr to query indexers for matching releases.

3. **Download Client Retrieves Files**  
   - Prowlarr sends the results to qBittorrent/NZBGet/Deluge/Transmission to start downloading.  
   - Gluetun ensures all download traffic is securely routed through a VPN.

4. **Files Are Processed & Organized**  
   - The *arr apps rename, sort, and move files to your media library for Plex or Jellyfin.  
   - Bazarr automatically searches for and downloads matching subtitles.

5. **User Access & Monitoring**  
   - Plex or Jellyfin serve the media to devices.  
   - Homepage/Homarr/Heimdall provide a central portal to access all services (including AMP).  
   - Portainer manages container health and logs.  
   - Watchtower automatically keeps everything up-to-date.  
   - Ansible can redeploy the entire environment with one command.

---

## 📂 Categories

| Category                | Apps                                                                 |
|-------------------------|----------------------------------------------------------------------|
| **Infrastructure**      | Gluetun, Portainer, Watchtower, Ansible                              |
| **Media Managers**      | Sonarr, Radarr, Lidarr, Bazarr, Yubal                                 |
| **Indexer Management**  | Prowlarr                                                             |
| **Download Clients**    | qBittorrent, NZBGet, Deluge, Transmission                            |
| **Media Requests**      | Seerr, Overseerr, Jellyseerr                                         |
| **Media Servers**       | Plex, Jellyfin, Tautulli                                             |
| **Photos & Files**      | Immich, Nextcloud                                                    |
| **Dashboards**          | Homepage, Homarr, Heimdall                                           |
| **Access & Utilities**  | Code Server, Gitea, Termix, Upsnap                                   |
| **Game Hosting**        | AMP (Application Management Panel)                                   |

---

## 🔗 Notes
- Choose **Plex** if you want official apps and easy remote access; choose **Jellyfin** if you prefer open-source and no subscriptions.
- **Seerr** is the current direction for requests, replacing separate Overseerr and Jellyseerr paths with one consolidated frontend.
- You don’t need all torrent clients — pick one based on preference.
- Bazarr works best when paired with Sonarr/Radarr to ensure subtitles are always present.
- Ansible is optional but recommended for advanced automated deployments.
- Gluetun is recommended for privacy and avoiding ISP throttling.
- Pi-hole, Nebula Sync, and Keepalived are a strong combination when you want more resilient DNS in the lab.
- Immich and Nextcloud cover different needs: photo backup versus broader personal cloud and collaboration.
- Authentik and Traefik become more valuable as the number of internal services grows.
- Code Server and Termix solve different access problems: one is editor-first, the other is terminal-first.
- Gitea is a good fit when you want internal Git hosting close to the rest of the lab services.
- AMP is independent from the media workflow but can be accessed through dashboards for convenience.
