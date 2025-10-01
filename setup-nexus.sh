#!/bin/bash

LOG_FILE="/workspaces/mawari-nexus-blueprint/nexus-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=============================================="
echo "  NEXUS NODE SETUP"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=============================================="

# Check secrets
if [ -z "$NEXUS_WALLET_ADDRESS" ]; then
    echo "❌ ERROR: Secret 'NEXUS_WALLET_ADDRESS' tidak ditemukan."
    echo "💡 Set secret di: https://github.com/<user>/<repo>/settings/secrets/codespaces"
    exit 1
fi

if [ -z "$NEXUS_NODE_ID" ]; then
    echo "❌ ERROR: Secret 'NEXUS_NODE_ID' tidak ditemukan."
    echo "💡 Get Node ID from: https://app.nexus.xyz/nodes"
    exit 1
fi

echo "✅ NEXUS_WALLET_ADDRESS found"
echo "✅ NEXUS_NODE_ID found"
echo "👤 Wallet: $NEXUS_WALLET_ADDRESS"
echo "🆔 Node ID: $NEXUS_NODE_ID"

# Install Nexus CLI
echo ""
echo "📦 Installing Nexus CLI..."
if ! command -v nexus-cli &> /dev/null; then
    curl -sSf https://cli.nexus.xyz/ -o /tmp/install.sh
    chmod +x /tmp/install.sh
    NONINTERACTIVE=1 /tmp/install.sh
    rm -f /tmp/install.sh
    
    # Reload PATH
    export PATH="$HOME/.cargo/bin:$PATH"
    echo "✅ Nexus CLI installed"
else
    echo "✅ Nexus CLI already installed"
fi

# Configure
echo ""
echo "⚙️  Configuring Nexus..."
rm -rf ~/.nexus
mkdir -p ~/.nexus

cat > ~/.nexus/config.json <<EOF
{
  "node_id": "$NEXUS_NODE_ID"
}
EOF

echo "✅ Config written to ~/.nexus/config.json"

# Register user (if needed)
echo ""
echo "🔐 Registering user..."
nexus-cli register-user --wallet-address "$NEXUS_WALLET_ADDRESS" || true

# Start Nexus
echo ""
echo "🚀 Starting Nexus node..."
echo "📊 Running with adaptive difficulty..."
echo ""

nexus-cli start --node-id "$NEXUS_NODE_ID" --headless

echo ""
echo "❌ Nexus node stopped"
