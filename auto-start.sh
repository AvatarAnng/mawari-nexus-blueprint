#!/bin/bash
# auto-start.sh - Run setiap kali codespace start/restart

WORKDIR="/workspaces/mawari-nexus-blueprint"
LOG_FILE="$WORKDIR/autostart.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "╔════════════════════════════════════════════════╗"
echo "║     AUTO START                                ║"
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

# Check if screen session exists
if screen -list | grep -q "$NODE_TYPE"; then
    echo "ℹ️  Screen session '$NODE_TYPE' already running"
else
    echo "🚀 Starting $NODE_TYPE in screen..."
    
    if [ "$NODE_TYPE" == "mawari" ]; then
        cd ~/mawari
        export MNTESTNET_IMAGE=us-east4-docker.pkg.dev/mawarinetwork-dev/mwr-net-d-car-uses4-public-docker-registry-e62e/mawari-node:latest
        export OWNER_ADDRESS="$MAWARI_OWNER_ADDRESS"
        
        screen -dmS mawari bash -c "docker run --pull always -v ~/mawari:/app/cache -e OWNERS_ALLOWLIST=\$OWNER_ADDRESS \$MNTESTNET_IMAGE"
        echo "✅ Mawari started in screen"
        
    elif [ "$NODE_TYPE" == "nexus" ]; then
        # Update CLI (untuk dapat update terbaru)
        cd /tmp
        curl -sSf https://cli.nexus.xyz/ -o install.sh
        chmod +x install.sh
        NONINTERACTIVE=1 ./install.sh
        
        export PATH="$HOME/.cargo/bin:$PATH"
        
        # Register & start
        screen -dmS nexus bash -c "nexus-cli register-user --wallet-address $NEXUS_WALLET_ADDRESS && nexus-cli start --node-id $NEXUS_NODE_ID --headless"
        echo "✅ Nexus started in screen"
    fi
fi

echo ""
echo "📊 To view: screen -r $NODE_TYPE"
echo "📊 To list: screen -ls"
echo "📝 Log: $LOG_FILE"
