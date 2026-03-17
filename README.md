# Grafana-loki-promtail-stack-installation
# 📊 Grafana + Loki + Promtail Stack

> **Simple, copy-paste ready setup** for log monitoring on any Linux server, VM, cloud instance, or local machine.  
> Works on: **Ubuntu / Debian / EC2 / DigitalOcean / bare metal / any apt-based system**

---

## 🗂️ What This Sets Up

| Tool | Purpose | Port |
|------|---------|------|
| **Grafana** | Dashboard UI | `3000` |
| **Loki** | Log aggregation backend | `3100` |
| **Promtail** | Log collector (ships logs → Loki) | — |

> ℹ️ **No Prometheus, no Docker Compose required** — just Docker + apt.

---

## ⚡ Quick Start — Choose Your Path

### ✅ Path A — Fresh Install (Grafana + Loki + Promtail)
> You have nothing installed yet.

```bash
git clone https://github.com/YOUR_USERNAME/grafana-loki-stack.git
cd grafana-loki-stack
chmod +x scripts/*.sh
sudo ./scripts/install-grafana.sh
./scripts/install-loki-promtail.sh
```

---

### ✅ Path B — Grafana Already Installed (Loki + Promtail Only)
> You already have Grafana running. Just need Loki + Promtail.

```bash
git clone https://github.com/YOUR_USERNAME/grafana-loki-stack.git
cd grafana-loki-stack
chmod +x scripts/*.sh
./scripts/install-loki-promtail.sh
```

Then skip to → **[Step 3: Connect Loki to Grafana](#step-3-connect-loki-to-grafana)**

---

## 📋 Prerequisites

- Ubuntu / Debian-based OS
- `sudo` access
- Docker installed → [Install Docker](https://docs.docker.com/engine/install/ubuntu/)

> **Check Docker is ready:**
> ```bash
> docker --version
> ```

---

## 🔧 Step-by-Step Guide

### Step 1 — Install Grafana (skip if already installed)

```bash
sudo ./scripts/install-grafana.sh
```

**What it does:**
- Adds Grafana's official apt repo
- Installs latest stable Grafana
- Starts and enables the systemd service

**Verify Grafana is running:**
```bash
sudo systemctl status grafana-server
```

Open in browser: **http://YOUR_SERVER_IP:3000**  
Default login: `admin` / `admin`

---

### Step 2 — Install Loki + Promtail (Docker)

```bash
./scripts/install-loki-promtail.sh
```

**What it does:**
- Downloads Loki config
- Starts Loki container on port `3100`
- Downloads Promtail config
- Starts Promtail container (ships `/var/log` → Loki)

**Verify containers are running:**
```bash
docker ps
```

You should see both `loki` and `promtail` containers running.

---

### Step 3 — Connect Loki to Grafana

1. Open Grafana → **http://YOUR_SERVER_IP:3000**
2. Login with `admin` / `admin`
3. Go to: **Configuration → Data Sources → Add data source**
4. Select **Loki**
5. Set URL to:
   ```
   http://localhost:3100
   ```
6. Click **Save & Test** → should show ✅ green

---

### Step 4 — View Your Logs

1. Go to **Explore** (compass icon in left sidebar)
2. Select **Loki** as the data source
3. Run a query:
   ```
   {job="varlogs"}
   ```
4. You should see your system logs! 🎉

---

## 📁 Repository Structure

```
grafana-loki-stack/
├── README.md                        ← You are here
├── scripts/
│   ├── install-grafana.sh           ← Installs Grafana via apt
│   └── install-loki-promtail.sh     ← Starts Loki + Promtail via Docker
├── configs/
│   ├── loki-config.yaml             ← Loki configuration
│   └── promtail-config.yaml         ← Promtail configuration
└── docs/
    ├── troubleshooting.md           ← Common issues & fixes
    └── adding-dashboards.md         ← Import pre-built dashboards
```

---

## 🛠️ Useful Commands

```bash
# Check container status
docker ps

# View Loki logs
docker logs loki

# View Promtail logs
docker logs promtail

# Restart Loki
docker restart loki

# Restart Promtail
docker restart promtail

# Stop everything
docker stop loki promtail

# Check Loki is reachable
curl http://localhost:3100/ready
```

---

## 🔄 Updating Loki / Promtail Version

Edit `scripts/install-loki-promtail.sh` and change the version tag:

```bash
LOKI_VERSION="2.8.0"   # Change this
```

Then re-run the script.

---

## ❓ Troubleshooting

See → [docs/troubleshooting.md](docs/troubleshooting.md)

---

## 📚 References

- [Grafana Docs](https://grafana.com/docs/grafana/latest/)
- [Loki Docs](https://grafana.com/docs/loki/latest/)
- [Promtail Docs](https://grafana.com/docs/loki/latest/clients/promtail/)
