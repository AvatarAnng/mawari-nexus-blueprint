#!/bin/bash

# =======================================================
# == CCTV AKTIF: Merekam semua output ke file log      ==
# =======================================================
exec > >(tee -a "/workspaces/mawari-nexus-blueprint/startup-debug.log") 2>&1

# --- KONFIGURASI ---
REPO_NAME="mawari-nexus-blueprint"
MAWARI_SESSION="mawari"
NEXUS_SESSION="nexus"
WORKDIR="/workspaces/$REPO_NAME"
# --------------------

echo "=============================================="
echo "    MEMULAI SKRIP SETUP NODE OTOMATIS (v.CCTV)"
echo "=============================================="

check_secret() {
  if [ -z "$1" ]; then
    echo "❌ ERROR: Secret '$2' tidak ditemukan."
    exit 1
  fi
}

echo -e "\n[NEXUS] Memeriksa instalasi..."
if ! command -v nexus-cli &> /dev/null; then
    echo "  -> nexus-cli tidak ditemukan. Menginstal..."
    if curl -sSf https://cli.nexus.xyz/ -o install.sh; then
        chmod +x install.sh
        NONINTERACTIVE=1 ./install.sh
        rm -f install.sh
        echo "✅ Instalasi Nexus selesai."
    else
        echo "❌ ERROR: Gagal download skrip instalasi Nexus."
        exit 1
    fi
else
    echo "✅ nexus-cli sudah terinstal."
fi

echo "[NEXUS] Menulis ulang konfigurasi dari secret..."
check_secret "$NEXUS_WALLET_ADDRESS" "NEXUS_WALLET_ADDRESS"
check_secret "$NEXUS_NODE_ID" "NEXUS_NODE_ID"

rm -rf ~/.nexus
mkdir -p ~/.nexus
echo "{\"node_id\":\"$NEXUS_NODE_ID\"}" > ~/.nexus/config.json
echo "✅ Konfigurasi Node ID Nexus berhasil ditulis ulang."

# Register user hanya jika belum terdaftar
if ! nexus-cli show-wallet 2>/dev/null | grep -q "$NEXUS_WALLET_ADDRESS"; then
    echo "🔐 Registrasi wallet address..."
    nexus-cli register-user --wallet-address "$NEXUS_WALLET_ADDRESS"
else
    echo "✅ Wallet sudah terdaftar."
fi

tmux has-session -t $NEXUS_SESSION 2>/dev/null
if [ $? != 0 ]; then
  echo "🚀 Membuat sesi tmux '$NEXUS_SESSION' dan menjalankan node Nexus..."
  tmux new-session -d -s $NEXUS_SESSION "nexus-cli start --node-id $NEXUS_NODE_ID --headless"
  echo "✅ Node Nexus sekarang berjalan di dalam tmux."
else
  echo "✅ Sesi tmux '$NEXUS_SESSION' sudah berjalan."
fi

echo -e "\n[MAWARI] Menyiapkan konfigurasi..."
check_secret "$MAWARI_OWNER_ADDRESS" "MAWARI_OWNER_ADDRESS"

# Cek apakah container mawari-node sudah running
if docker ps --format '{{.Names}}' | grep -q "^mawari-node$"; then
    echo "✅ Container mawari-node sudah berjalan."
else
    # Stop dan hapus container lama jika ada (tapi tidak running)
    if docker ps -a --format '{{.Names}}' | grep -q "^mawari-node$"; then
        echo "🧹 Membersihkan container lama..."
        docker rm -f mawari-node 2>/dev/null
    fi
    
    tmux has-session -t $MAWARI_SESSION 2>/dev/null
    if [ $? != 0 ]; then
        echo "🚀 Membuat sesi tmux '$MAWARI_SESSION' dan menjalankan node Mawari..."
        export OWNER_ADDRESS="$MAWARI_OWNER_ADDRESS"
        export MNTESTNET_IMAGE=us-east4-docker.pkg.dev/mawarinetwork-dev/mwr-net-d-car-uses4-public-docker-registry-e62e/mawari-node:latest
        
        rm -rf $WORKDIR/mawari_data
        mkdir -p $WORKDIR/mawari_data

        tmux new-session -d -s $MAWARI_SESSION "docker run --pull always --rm --name mawari-node -v $WORKDIR/mawari_data:/app/cache -e OWNERS_ALLOWLIST=\$OWNER_ADDRESS \$MNTESTNET_IMAGE"
        
        echo "✅ Node Mawari sekarang berjalan di dalam tmux."
    else
        echo "✅ Sesi tmux '$MAWARI_SESSION' sudah berjalan."
    fi
fi

echo -e "\n=============================================="
echo "      SETUP SELESAI. SEMUA NODE AKTIF."
echo "=============================================="
echo ""
echo "📊 Untuk melihat status:"
echo "   - Nexus: tmux attach -t nexus"
echo "   - Mawari: tmux attach -t mawari"
echo "   - Docker: docker ps"
echo ""
echo "⌨️  Untuk keluar dari tmux: Ctrl+B lalu D"
echo ""

# Perintah sakti buat ngasih tanda kalo semua beneran beres
touch /tmp/startup_success
