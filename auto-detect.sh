#!/bin/bash
# =======================================================
# AUTO-DETECT.SH - Deteksi codespace type dan jalankan setup yang sesuai
# =======================================================

WORKDIR="/workspaces/mawari-nexus-blueprint"
LOG_FILE="$WORKDIR/auto-detect.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "╔════════════════════════════════════════════════╗"
echo "║     AUTO-DETECT CODESPACE TYPE                ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "📅 $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Deteksi nama codespace dari environment
CODESPACE_NAME="${CODESPACE_NAME:-unknown}"
echo "🔍 Codespace Name: $CODESPACE_NAME"

# Deteksi berdasarkan display name atau nama codespace
if [[ "$CODESPACE_NAME" == *"mawari"* ]] || [[ "$CODESPACE_NAME" == *"Mawari"* ]]; then
    NODE_TYPE="mawari"
elif [[ "$CODESPACE_NAME" == *"nexus"* ]] || [[ "$CODESPACE_NAME" == *"Nexus"* ]]; then
    NODE_TYPE="nexus"
else
    # Fallback: cek machine size
    # basicLinux32gb = Mawari
    # standardLinux32gb = Nexus
    MACHINE_TYPE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/user/codespaces/$CODESPACE_NAME" 2>/dev/null \
        | jq -r '.machine.name' 2>/dev/null)
    
    echo "🖥️  Machine Type: $MACHINE_TYPE"
    
    if [[ "$MACHINE_TYPE" == *"basic"* ]]; then
        NODE_TYPE="mawari"
    elif [[ "$MACHINE_TYPE" == *"standard"* ]]; then
        NODE_TYPE="nexus"
    else
        echo "❌ Cannot detect node type!"
        echo "💡 Set CODESPACE_NAME manually or check machine type"
        exit 1
    fi
fi

echo ""
echo "✅ Detected Node Type: $NODE_TYPE"
echo "════════════════════════════════════════════════"
echo ""

# Jalankan setup yang sesuai
if [ "$NODE_TYPE" == "mawari" ]; then
    echo "🌐 Running Mawari Setup..."
    bash "$WORKDIR/setup-mawari.sh"
elif [ "$NODE_TYPE" == "nexus" ]; then
    echo "🔷 Running Nexus Setup..."
    bash "$WORKDIR/setup-nexus.sh"
else
    echo "❌ Unknown node type: $NODE_TYPE"
    exit 1
fi

echo ""
echo "════════════════════════════════════════════════"
echo "Setup script completed at $(date '+%Y-%m-%d %H:%M:%S')"
echo "Log saved to: $LOG_FILE"
