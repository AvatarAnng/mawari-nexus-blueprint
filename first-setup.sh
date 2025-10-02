#!/bin/bash
# first-setup.sh - Hanya run saat codespace PERTAMA KALI dibuat

WORKDIR="/workspaces/mawari-nexus-blueprint"
LOG_FILE="$WORKDIR/setup.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "╔════════════════════════════════════════════════╗"
echo "║     FIRST TIME SETUP                          ║"
echo "╚════════════════════════════════════════════════╝"
echo "📅 $(date '+%Y-%m-%d %H:%M:%S')"

CODESPACE_NAME="${CODESPACE_NAME:-unknown}"
echo "🔍 Codespace: $CODESPACE_NAME"

# Detect node type
if [[ "$CODESPACE_NAME" == *"mawari"* ]]; then
    NODE_TYPE="mawari"
elif [[ "$CODESPACE_NAME" == *"nexus"* ]]; then
    NODE_TYPE="nexus"
else
    echo "❌ Cannot detect node type"
    exit 1
fi

echo "✅ Node Type: $NODE_TYPE"
echo ""

if [ "$NODE_TYPE" == "mawari" ]; then
    echo "🌐 Setting up Mawari..."
    
    # Create directory
    mkdir -p ~/mawari/mawari_data
    cd ~/mawari/mawari_data
    
    # Create flohive-cache.json
    cat > flohive-cache.json <<EOF
{
  "owner_address": "$MAWARI_OWNER_ADDRESS"
}
EOF
    
    echo "✅ Mawari directory created"
    echo "✅ flohive-cache.json created"
    
elif [ "$NODE_TYPE" == "nexus" ]; then
    echo "🔷 Setting up Nexus..."
    
    # Install Nexus CLI
    cd /tmp
    curl -sSf https://cli.nexus.xyz/ -o install.sh
    chmod +x install.sh
    NONINTERACTIVE=1 ./install.sh
    
    # Reload PATH
    export PATH="$HOME/.cargo/bin:$PATH"
    
    echo "✅ Nexus CLI installed"
fi

echo ""
echo "════════════════════════════════════════════════"
echo "✅ First setup complete"
echo "📝 Log: $LOG_FILE"
