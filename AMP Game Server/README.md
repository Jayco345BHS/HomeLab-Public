
# 🪓 Minecraft Java Server — AMP on Ubuntu 24.04 LTS

This guide will take you from a **fresh Ubuntu 24.04 LTS VM** to a fully running **Minecraft Java server** managed by **[AMP (Application Management Panel)](https://cubecoders.com/AMP)**.  

It includes **all commands**, **a one-block install script**, and **merged setup + management instructions** for easy GitHub use.

---

## 📋 Overview

- **OS:** [Ubuntu 24.04 LTS](https://ubuntu.com/download/server)
- **Server Type:** Minecraft Java Edition
- **Management Tool:** [CubeCoders AMP](https://cubecoders.com/AMP)
- **VM Purpose:** Game server hosting with a web UI
- **Features:**
  - Web-based admin panel
  - Plugin & mod support
  - Scheduled backups & restarts
  - Live console logging & performance stats
  - Multi-instance hosting

---

## 🖥 Recommended VM Specs

| Component  | Recommended |
|------------|-------------|
| CPU        | 4+ cores    |
| RAM        | 6–8 GB (plus 1–2 GB for OS) |
| Storage    | 20 GB+ SSD/NVMe |
| Network    | Static IP or DHCP reservation |

---

## 🚀 One-Block Setup Script

This script installs **AMP**, enables it on boot, creates a Minecraft server instance, and opens the required ports.

> ⚠️ Run on a **fresh Ubuntu 24.04 LTS VM** for best results.

---

```bash
# 1. Update & install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install curl unzip ufw -y

# 2. Create AMP user
sudo adduser amp --gecos ""
sudo usermod -aG sudo amp

# 3. Switch to AMP user and install AMP
su - amp <<'EOF'
wget https://cubecoders.com/Downloads/ampinstmgr.zip
unzip ampinstmgr.zip
cd AMP
./ampinstmgr install
EOF

# 4. Enable & start AMP service
sudo systemctl enable amp
sudo systemctl start amp
sudo systemctl status amp --no-pager

# 5. Switch to AMP user again to create Minecraft instance
su - amp <<'EOF'
ampinstmgr CreateInstance Minecraft01 MinecraftJava
EOF

# 6. Open firewall ports (Minecraft + AMP Web)
sudo ufw allow 25565/tcp
sudo ufw allow 8080/tcp
sudo ufw enable

echo "✅ Setup complete!"
echo "🌐 Access AMP Web: http://<your-server-ip>:8080"
echo "🔑 Login with the credentials you set during AMP install"
echo "📌 Change your password immediately for security"
```

---

## 🛠 Post-Install Setup, Commands & Troubleshooting

After running the one-block script:

1. **Log into AMP Web Panel**:  
   [http://\<server-ip\>:8080](http://<server-ip>:8080)  
   Login with the credentials you set during install.
2. **Select the `Minecraft01` instance**
3. **Choose server type**:
   - [Paper](https://papermc.io/) (recommended for performance & plugins)
   - Vanilla
   - [Spigot](https://www.spigotmc.org/)
   - [Fabric](https://fabricmc.net/) / [Forge](https://files.minecraftforge.net/)
4. **Accept the EULA** (`true` in settings)
5. **Configure server settings**:
   - MOTD / Server Name
   - Max Players
   - Difficulty
   - World Seed
6. **Start the server** from the web panel

---

### 📜 Common Commands

| Task                       | Command |
|----------------------------|---------|
| Start AMP                  | `sudo systemctl start amp` |
| Stop AMP                   | `sudo systemctl stop amp` |
| Restart AMP                | `sudo systemctl restart amp` |
| Check AMP status           | `sudo systemctl status amp` |
| List AMP instances         | `su - amp -c "ampinstmgr list"` |
| Update AMP                 | `su - amp -c "ampinstmgr upgrade"` |
| Update Ubuntu              | `sudo apt update && sudo apt upgrade -y` |

---

### 🛠 Troubleshooting

**AMP Web Panel Not Loading**
```bash
sudo systemctl status amp
sudo journalctl -u amp --no-pager --lines=50
```
- Ensure firewall allows port `8080`
- Check if another service is using port:
```bash
sudo lsof -i:8080
```

**Minecraft Clients Can't Connect**
- Check firewall rules:
```bash
sudo ufw status
```
- Verify router port forwarding for `25565/TCP`

**Low TPS / Lag**
- Use **Paper**
- Lower **view-distance** in `server.properties`
- Increase allocated RAM in AMP instance settings

**AMP Not Starting on Boot**
```bash
sudo systemctl enable amp
sudo systemctl daemon-reload
```

---

## 🔗 Useful Links

- [CubeCoders AMP](https://cubecoders.com/AMP)
- [Minecraft Server Wiki](https://minecraft.fandom.com/wiki/Server)
- [PaperMC Downloads](https://papermc.io/downloads)
- [SpigotMC](https://www.spigotmc.org/)
- [FabricMC](https://fabricmc.net/)
- [Forge](https://files.minecraftforge.net/)

---

## 📌 Notes

- This guide is for **personal hosting**.
- Minecraft is owned by Mojang Studios.  
- AMP is developed by CubeCoders Limited.  
- All trademarks belong to their respective owners.
