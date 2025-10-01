#!/bin/bash
# =======================================================
# setup-mawari.sh - HANYA UNTUK MAWARI NODE
# =======================================================

LOG_FILE="/workspaces/mawari-nexus-blueprint/mawari-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=============================================="
echo "  MAWARI NODE SETUP"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================================="

# Check secret
if [ -z "$MAWARI_OWNER_ADDRESS" ]; then
    echo "❌ ERROR: Secret 'MAWARI_OWNER_ADDRESS' tidak ditemukan."
    echo "💡 Set secret di: https://github.com/<user>/<repo>/settings/secrets/codespaces"
    exit 1
fi

echo "✅ MAWARI_OWNER_ADDRESS found"
echo "🌐 Owner Address: $MAWARI_OWNER_ADDRESS"

# Setup directories
WORKDIR="/workspaces/mawari-nexus-blueprint"
mkdir -p "$WORKDIR/mawari_data"

# Set environment
export OWNER_ADDRESS="$MAWARI_OWNER_ADDRESS"
export MNTESTNET_IMAGE="us-east4-docker.pkg.dev/mawarinetwork-dev/mwr-net-d-car-uses4-public-docker-registry-e62e/mawari-node:latest"

echo "🐳 Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found!"
    exit 1
fi
echo "✅ Docker available"

# Cleanup old container
if docker ps -a --format '{{.Names}}' | grep -q "^mawari-node$"; then
    echo "🧹 Removing old container..."
    docker rm -f mawari-node
fi

echo "🚀 Starting Mawari Guardian Node..."
docker run --pull always --rm --name mawari-node \
    -v "$WORKDIR/mawari_data:/app/cache" \
    -e OWNERS_ALLOWLIST=$OWNER_ADDRESS \
    $MNTESTNET_IMAGE &

DOCKER_PID=$!
echo "✅ Mawari node started (PID: $DOCKER_PID)"
echo "📝 Log file: $LOG_FILE"
echo ""
echo "🔍 To view logs:"
echo "   docker logs -f mawari-node"
echo ""
echo "🔑 To find burner address:"
echo "   cat $WORKDIR/mawari_data/flohive-cache.json"
echo ""

# Wait for container
wait $DOCKER_PID
