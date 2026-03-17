#!/bin/bash
# =============================================================================
# install-grafana.sh
# Installs Grafana (stable) on Ubuntu / Debian
# Usage: sudo ./scripts/install-grafana.sh
# =============================================================================

set -e  # Exit immediately if any command fails

echo ""
echo "============================================"
echo "  Installing Grafana on $(lsb_release -d | cut -f2)"
echo "============================================"
echo ""

# --- Step 1: Install dependencies ---
echo "[1/5] Installing dependencies..."
apt-get install -y apt-transport-https software-properties-common wget

# --- Step 2: Add Grafana GPG key ---
echo "[2/5] Adding Grafana GPG key..."
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key

# --- Step 3: Add Grafana stable apt repo ---
echo "[3/5] Adding Grafana stable apt repository..."
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" \
  | tee /etc/apt/sources.list.d/grafana.list

# --- Step 4: Install Grafana ---
echo "[4/5] Updating package list and installing Grafana..."
apt-get update -q
apt-get install -y grafana

# --- Step 5: Start and enable Grafana service ---
echo "[5/5] Starting Grafana service..."
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server

# --- Done ---
echo ""
echo "============================================"
echo "  ✅ Grafana installed successfully!"
echo "============================================"
echo ""
echo "  Service status:"
systemctl status grafana-server --no-pager -l
echo ""
echo "  👉 Open Grafana at: http://$(hostname -I | awk '{print $1}'):3000"
echo "  👉 Default login:   admin / admin"
echo ""
