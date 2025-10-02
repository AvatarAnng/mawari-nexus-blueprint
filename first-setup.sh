#!/bin/bash
# first-setup.sh - Run saat codespace pertama kali dibuat

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
    
    # Validate secrets
    if [ -z "$MAWARI_BURNER_PRIVATE_KEY" ]; then
        echo "❌ ERROR: MAWARI_BURNER_PRIVATE_KEY tidak ditemukan!"
        exit 1
    fi
    
    if [ -z "$MAWARI_BURNER_ADDRESS" ]; then
        echo "❌ ERROR: MAWARI_BURNER_ADDRESS tidak ditemukan!"
        exit 1
    fi
    
    if [ -z "$MAWARI_OWNER_ADDRESS" ]; then
        echo "❌ ERROR: MAWARI_OWNER_ADDRESS tidak ditemukan!"
        exit 1
    fi
    
    echo "✅ Burner wallet: $MAWARI_BURNER_ADDRESS"
    echo "✅ Owner address: $MAWARI_OWNER_ADDRESS"
    
    # Create directory
    mkdir -p ~/mawari/mawari_data
    
    # Create flohive-cache.json (EXACT path Docker expects)
    cat > ~/mawari/mawari_data/flohive-cache.json <<'EOF'
{
  "burnerWallet": {
    "privateKey": "PRIVATE_KEY_PLACEHOLDER",
    "address": "ADDRESS_PLACEHOLDER"
  }
}
EOF
    
    # Replace placeholders
    sed -i "s|PRIVATE_KEY_PLACEHOLDER|$MAWARI_BURNER_PRIVATE_KEY|g" ~/mawari/mawari_data/flohive-cache.json
    sed -i "s|ADDRESS_PLACEHOLDER|$MAWARI_BURNER_ADDRESS|g" ~/mawari/mawari_data/flohive-cache.json
    
    echo "✅ Mawari directory created"
    echo "✅ flohive-cache.json created"
    
    # Verify file
    echo "📄 Cache file content:"
    cat ~/mawari/mawari_data/flohive-cache.json
    
    # Set permissions
    chmod 644 ~/mawari/mawari_data/flohive-cache.json
    
elif [ "$NODE_TYPE" == "nexus" ]; then
    echo "🔷 Setting up Nexus..."
    
    # Validate secrets
    if [ -z "$NEXUS_WALLET_ADDRESS" ]; then
        echo "❌ ERROR: NEXUS_WALLET_ADDRESS tidak ditemukan!"
        exit 1
    fi
    
    if [ -z "$NEXUS_NODE_ID" ]; then
        echo "❌ ERROR: NEXUS_NODE_ID tidak ditemukan!"
        exit 1
    fi
    
    echo "✅ Wallet: $NEXUS_WALLET_ADDRESS"
    echo "✅ Node ID: $NEXUS_NODE_ID"
    
    # Install Nexus CLI
    cd /tmp
    curl -sSf https://cli.nexus.xyz/ -o install.sh
    chmod +x install.sh
    NONINTERACTIVE=1 ./install.sh
    rm -f install.sh
    
    # Reload PATH
    source /home/vscode/.profile
    
    # Install tmux
    echo "Installing tmux..."
    sudo apt-get update && sudo apt-get install -y tmux
    
    echo "✅ Nexus CLI installed"
    echo "✅ tmux installed"
fi

echo ""
echo "════════════════════════════════════════════════"
echo "✅ First setup complete"
echo "📝 Log: $LOG_FILE"

touch /tmp/first_setup_done
