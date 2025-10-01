#!/bin/bash

# =======================================================
# STARTUP SCRIPT - MAWARI & NEXUS NODE
# Kontrol penuh dari laptop via orchestrator
# =======================================================

LOG_FILE="/workspaces/mawari-nexus-blueprint/startup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

REPO_NAME="mawari-nexus-blueprint"
MAWARI_SESSION="mawari"
NEXUS_SESSION="nexus"
WORKDIR="/workspaces/$REPO_NAME"

echo "=============================================="
echo "  AUTO SETUP - MAWARI & NEXUS NODES"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================================="

# Fungsi untuk cek secret
check_secret() {
  if [ -z "$1" ]; then
    echo "❌ ERROR: Secret '$2' tidak ditemukan."
    exit 1
  fi
}

# ==========================================
# NEXUS SETUP
# ==========================================
echo -e "\n[NEXUS] Checking installation..."
if ! command -v nexus-cli &> /dev/null; then
    echo "  → Installing nexus-cli..."
    if curl -sSf https://cli.nexus.xyz/ -o /tmp/install.sh; then
        chmod +x /tmp/install.sh
        NONINTERACTIVE=1 /tmp/install.sh
        rm -f /tmp/install.sh
        echo "✅ Nexus CLI installed"
    else
        echo "❌ Failed to download Nexus installer"
        exit 1
    fi
else
    echo "✅ nexus-cli already installed"
fi

echo "[NEXUS] Configuring..."
check_secret "$NEXUS_WALLET_ADDRESS" "NEXUS_WALLET_ADDRESS"
check_secret "$NEXUS_NODE_ID" "NEXUS_NODE_ID"

# Clean config
rm -rf ~/.nexus
mkdir -p ~/.nexus
cat > ~/.nexus/config.json <<EOF
{
  "node_id": "$NEXUS_NODE_ID"
}
EOF

echo "✅ Nexus config written"

# Register wallet (skip jika sudah)
if ! nexus-cli show-wallet 2>/dev/null | grep -q "$NEXUS_WALLET_ADDRESS"; then
    echo "🔐 Registering wallet..."
    nexus-cli register-user --wallet-address "$NEXUS_WALLET_ADDRESS"
else
    echo "✅ Wallet already registered"
fi

# Start dalam tmux
if ! tmux has-session -t $NEXUS_SESSION 2>/dev/null; then
    echo "🚀 Starting Nexus node in tmux..."
    tmux new-session -d -s $NEXUS_SESSION "nexus-cli start --node-id $NEXUS_NODE_ID --headless"
    echo "✅ Nexus node running in tmux session: $NEXUS_SESSION"
else
    echo "✅ Nexus tmux session already exists"
fi

# ==========================================
# MAWARI SETUP
# ==========================================
echo -e "\n[MAWARI] Configuring..."
check_secret "$MAWARI_OWNER_ADDRESS" "MAWARI_OWNER_ADDRESS"

# Cek container status
if docker ps --format '{{.Names}}' | grep -q "^mawari-node$"; then
    echo "✅ Mawari container already running"
elif docker ps -a --format '{{.Names}}' | grep -q "^mawari-node$"; then
    echo "🧹 Cleaning old container..."
    docker rm -f mawari-node 2>/dev/null
    echo "✅ Old container removed"
fi

# Start mawari jika belum running
if ! docker ps --format '{{.Names}}' | grep -q "^mawari-node$"; then
    if ! tmux has-session -t $MAWARI_SESSION 2>/dev/null; then
        echo "🚀 Starting Mawari node in tmux..."
        
        export OWNER_ADDRESS="$MAWARI_OWNER_ADDRESS"
        export MNTESTNET_IMAGE="us-east4-docker.pkg.dev/mawarinetwork-dev/mwr-net-d-car-uses4-public-docker-registry-e62e/mawari-node:latest"
        
        # Prepare data directory
        rm -rf "$WORKDIR/mawari_data"
        mkdir -p "$WORKDIR/mawari_data"

        # Start dalam tmux
        tmux new-session -d -s $MAWARI_SESSION \
            "docker run --pull always --rm --name mawari-node \
            -v $WORKDIR/mawari_data:/app/cache \
            -e OWNERS_ALLOWLIST=$OWNER_ADDRESS \
            $MNTESTNET_IMAGE"
        
        echo "✅ Mawari node running in tmux session: $MAWARI_SESSION"
    else
        echo "✅ Mawari tmux session already exists"
    fi
fi

# ==========================================
# FINAL STATUS
# ==========================================
echo -e "\n=============================================="
echo "           ✅ SETUP COMPLETE"
echo "=============================================="
echo ""
echo "📊 Status Check:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "NAME|mawari"
echo ""
echo "🎮 Control Commands:"
echo "  • View Nexus : tmux attach -t nexus"
echo "  • View Mawari: tmux attach -t mawari"
echo "  • Docker Logs: docker logs -f mawari-node"
echo "  • Exit tmux  : Ctrl+B then D"
echo ""
echo "📝 Log file: $LOG_FILE"
echo "=============================================="

# Success marker
touch /tmp/startup_success
echo "✅ Startup timestamp: $(date '+%Y-%m-%d %H:%M:%S')" > /tmp/startup_success
