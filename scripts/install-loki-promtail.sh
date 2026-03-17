#!/bin/bash
# =============================================================================
# install-loki-promtail.sh
# Installs Loki + Promtail using Docker containers
# Usage: ./scripts/install-loki-promtail.sh
#
# Requirements:
#   - Docker must be installed (https://docs.docker.com/engine/install/ubuntu/)
#   - Run from the ROOT of this repo (not from inside /scripts)
# =============================================================================

set -e

LOKI_VERSION="2.8.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="$REPO_ROOT/configs"

echo ""
echo "============================================"
echo "  Installing Loki + Promtail v${LOKI_VERSION}"
echo "============================================"
echo ""

# --- Check Docker is available ---
if ! command -v docker &> /dev/null; then
  echo "❌ Docker is not installed. Please install Docker first:"
  echo "   https://docs.docker.com/engine/install/ubuntu/"
  exit 1
fi
echo "✅ Docker found: $(docker --version)"

# --- Stop + remove existing containers if any ---
echo ""
echo "[1/4] Cleaning up any existing Loki/Promtail containers..."
docker rm -f loki 2>/dev/null && echo "  Removed old loki container" || echo "  No existing loki container"
docker rm -f promtail 2>/dev/null && echo "  Removed old promtail container" || echo "  No existing promtail container"

# --- Download configs if not already present ---
echo ""
echo "[2/4] Checking configuration files..."

if [ ! -f "$CONFIG_DIR/loki-config.yaml" ]; then
  echo "  Downloading loki-config.yaml..."
  wget -q "https://raw.githubusercontent.com/grafana/loki/v${LOKI_VERSION}/cmd/loki/loki-local-config.yaml" \
    -O "$CONFIG_DIR/loki-config.yaml"
  echo "  ✅ loki-config.yaml downloaded"
else
  echo "  ✅ loki-config.yaml already exists, skipping download"
fi

if [ ! -f "$CONFIG_DIR/promtail-config.yaml" ]; then
  echo "  Downloading promtail-config.yaml..."
  wget -q "https://raw.githubusercontent.com/grafana/loki/v${LOKI_VERSION}/clients/cmd/promtail/promtail-docker-config.yaml" \
    -O "$CONFIG_DIR/promtail-config.yaml"
  echo "  ✅ promtail-config.yaml downloaded"
else
  echo "  ✅ promtail-config.yaml already exists, skipping download"
fi

# --- Start Loki ---
echo ""
echo "[3/4] Starting Loki container..."
docker run -d \
  --name loki \
  --restart unless-stopped \
  -v "$CONFIG_DIR":/mnt/config \
  -p 3100:3100 \
  grafana/loki:${LOKI_VERSION} \
  --config.file=/mnt/config/loki-config.yaml

echo "  ✅ Loki container started"

# Wait for Loki to be ready
echo "  ⏳ Waiting for Loki to be ready..."
for i in {1..15}; do
  if curl -s http://localhost:3100/ready | grep -q "ready"; then
    echo "  ✅ Loki is ready!"
    break
  fi
  sleep 2
  echo "  ... waiting ($i/15)"
done

# --- Start Promtail ---
echo ""
echo "[4/4] Starting Promtail container..."
docker run -d \
  --name promtail \
  --restart unless-stopped \
  -v "$CONFIG_DIR":/mnt/config \
  -v /var/log:/var/log:ro \
  --link loki \
  grafana/promtail:${LOKI_VERSION} \
  --config.file=/mnt/config/promtail-config.yaml

echo "  ✅ Promtail container started"

# --- Summary ---
echo ""
echo "============================================"
echo "  ✅ Loki + Promtail installed!"
echo "============================================"
echo ""
echo "  Running containers:"
docker ps --filter "name=loki" --filter "name=promtail" --format "  • {{.Names}}  ({{.Status}})"
echo ""
echo "  Loki API:      http://$(hostname -I | awk '{print $1}'):3100"
echo "  Loki ready?    curl http://localhost:3100/ready"
echo ""
echo "  ─────────────────────────────────────────"
echo "  NEXT STEP — Connect Loki to Grafana:"
echo "  ─────────────────────────────────────────"
echo "  1. Open Grafana → http://$(hostname -I | awk '{print $1}'):3000"
echo "  2. Go to: Configuration → Data Sources → Add data source"
echo "  3. Select: Loki"
echo "  4. URL: http://localhost:3100"
echo "  5. Click: Save & Test"
echo ""
echo "  Then go to Explore → select Loki → query: {job=\"varlogs\"}"
echo ""
