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

# MAWARI - USE DOCKER
if [ "$NODE_TYPE" == "mawari" ]; then
    # Check if already running
    if docker ps | grep -q mawari-node; then
        echo "ℹ️  Mawari container already running"
    else
        echo "🚀 Starting Mawari container..."
        
        # Validate secrets
        if [ -z "$MAWARI_BURNER_PRIVATE_KEY" ]; then
            echo "❌ ERROR: MAWARI_BURNER_PRIVATE_KEY tidak tersedia!"
            exit 1
        fi
        
        if [ -z "$MAWARI_BURNER_ADDRESS" ]; then
            echo "❌ ERROR: MAWARI_BURNER_ADDRESS tidak tersedia!"
            exit 1
        fi
        
        if [ -z "$MAWARI_OWNER_ADDRESS" ]; then
            echo "❌ ERROR: MAWARI_OWNER_ADDRESS tidak tersedia!"
            exit 1
        fi
        
        echo "✅ Using burner: $MAWARI_BURNER_ADDRESS"
        echo "✅ Using owner: $MAWARI_OWNER_ADDRESS"
        
        cd ~/mawari
        
        # Stop old container if exists
        docker rm -f mawari-node 2>/dev/null || true
        
        export MNTESTNET_IMAGE=us-east4-docker.pkg.dev/mawarinetwork-dev/mwr-net-d-car-uses4-public-docker-registry-e62e/mawari-node:latest
        
        # Run in detached mode
        docker run -d \
            --name mawari-node \
            --pull always \
            -v ~/mawari/mawari_data:/app/cache \
            -e OWNERS_ALLOWLIST="$MAWARI_OWNER_ADDRESS" \
            $MNTESTNET_IMAGE
        
        echo "✅ Mawari container started"
        sleep 3
        docker ps | grep mawari-node
    fi
fi

# NEXUS - USE TMUX
if [ "$NODE_TYPE" == "nexus" ]; then
    # Validate secrets
    if [ -z "$NEXUS_WALLET_ADDRESS" ]; then
        echo "❌ ERROR: NEXUS_WALLET_ADDRESS tidak tersedia!"
        exit 1
    fi
    
    if [ -z "$NEXUS_NODE_ID" ]; then
        echo "❌ ERROR: NEXUS_NODE_ID tidak tersedia!"
        exit 1
    fi
    
    echo "✅ Using wallet: $NEXUS_WALLET_ADDRESS"
    echo "✅ Using node ID: $NEXUS_NODE_ID"
    
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
        
        # Register user
        echo "Registering with wallet: $NEXUS_WALLET_ADDRESS"
        nexus-cli register-user --wallet-address "$NEXUS_WALLET_ADDRESS" || true
        
        # Start in tmux
        tmux new-session -d -s nexus "nexus-cli start --node-id $NEXUS_NODE_ID --headless"
        echo "✅ Nexus started in tmux"
    fi
fi

echo ""
echo "📊 View logs:"
if [ "$NODE_TYPE" == "mawari" ]; then
    echo "   docker logs -f mawari-node"
    echo "   docker ps"
else
    echo "   tmux attach -t nexus"
    echo "   (Detach: Ctrl+B then D)"
fi
echo "📝 Log: $LOG_FILE"

touch /tmp/auto_start_done
