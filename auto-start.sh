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

# MAWARI - USE SCREEN
if [ "$NODE_TYPE" == "mawari" ]; then
    if screen -list | grep -q "mawari"; then
        echo "ℹ️  Screen session 'mawari' already running"
    else
        echo "🚀 Starting Mawari in screen..."
        
        cd ~/mawari
        export MNTESTNET_IMAGE=us-east4-docker.pkg.dev/mawarinetwork-dev/mwr-net-d-car-uses4-public-docker-registry-e62e/mawari-node:latest
        export OWNER_ADDRESS="$MAWARI_OWNER_ADDRESS"
        
        screen -dmS mawari bash -c "docker run --pull always -v ~/mawari:/app/cache -e OWNERS_ALLOWLIST=\$OWNER_ADDRESS \$MNTESTNET_IMAGE"
        echo "✅ Mawari started in screen"
    fi
fi

# NEXUS - USE TMUX
if [ "$NODE_TYPE" == "nexus" ]; then
    # Update Nexus CLI
    echo "🔄 Updating Nexus CLI..."
    cd /tmp
    curl -sSf https://cli.nexus.xyz/ -o install.sh
    chmod +x install.sh
    NONINTERACTIVE=1 ./install.sh
    rm -f install.sh
    
    # Load PATH
    source /home/vscode/.profile
    
    if tmux has-session -t nexus 2>/dev/null; then
        echo "ℹ️  Tmux session 'nexus' already running"
    else
        echo "🚀 Starting Nexus in tmux..."
        
        # Register user first
        nexus-cli register-user --wallet-address "$NEXUS_WALLET_ADDRESS" || true
        
        # Start in tmux
        tmux new-session -d -s nexus "nexus-cli start --node-id $NEXUS_NODE_ID --headless"
        echo "✅ Nexus started in tmux"
    fi
fi

echo ""
echo "📊 View logs:"
if [ "$NODE_TYPE" == "mawari" ]; then
    echo "   screen -r mawari"
    echo "   (Detach: Ctrl+A then D)"
else
    echo "   tmux attach -t nexus"
    echo "   (Detach: Ctrl+B then D)"
fi
echo "📝 Log: $LOG_FILE"

# Mark as done
touch /tmp/auto_start_done
