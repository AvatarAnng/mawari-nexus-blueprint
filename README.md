# Mawari & Nexus Node Blueprint

Automated deployment untuk Mawari Guardian Node dan Nexus Prover di GitHub Codespaces dengan orchestrator lokal.

---

## 🎯 Fitur

- **Auto-detect node type** berdasarkan display name codespace
- **Auto-install & setup** saat codespace pertama kali dibuat
- **Auto-restart** saat codespace bangun dari idle/shutdown
- **Multi-account rotation** via orchestrator (20 jam per akun)
- **Persistent burner wallet** untuk Mawari node

---

## 📋 Requirements

### Repository Secrets (GitHub Codespaces)
Set di: `https://github.com/USERNAME/REPO/settings/secrets/codespaces`

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `MAWARI_OWNER_ADDRESS` | Ethereum address pemilik node | `0xYourAddress...` |
| `MAWARI_BURNER_ADDRESS` | Burner wallet address | `0xBurnerAddress...` |
| `MAWARI_BURNER_PRIVATE_KEY` | Burner wallet private key | `0x1234abcd...` |
| `NEXUS_WALLET_ADDRESS` | Ethereum address untuk Nexus | `0xYourAddress...` |
| `NEXUS_NODE_ID` | Node ID dari Nexus dashboard | `12345678` |

**Cara dapat secrets:**

**Mawari:**
- `MAWARI_OWNER_ADDRESS`: Address wallet utama Anda
- `MAWARI_BURNER_ADDRESS` & `MAWARI_BURNER_PRIVATE_KEY`: Generate burner wallet baru di Metamask atau wallet lain, jangan pakai wallet utama!

**Nexus:**
- Buka https://app.nexus.xyz/nodes
- Login dengan wallet → Create new node → Copy Node ID

---

## 🚀 Cara Deploy

### Otomatis via Orchestrator (Recommended)
Orchestrator akan otomatis create codespace dengan config yang benar. Lihat dokumentasi di folder `codespace-orchestrator`.

**Quick start:**
```bash
cd D:\SC\codespace-orchestrator
.\start-otak.bat Kyugito666/mawari-nexus-blueprint
```

### Manual Deploy via GitHub UI
1. Fork repository ini
2. Set 5 secrets di repo settings (lihat tabel di atas)
3. Buka https://github.com/codespaces
4. Click "New codespace" → Pilih repo ini
5. Pilih machine:
   - **basicLinux32gb** untuk Mawari (display name: `mawari-node`)
   - **standardLinux32gb** untuk Nexus (display name: `nexus-node`)
6. Tunggu 2-3 menit untuk setup
7. Node akan auto-start

---

## 📊 Monitoring

### Cek Status via Orchestrator
```bash
cd D:\SC\codespace-orchestrator
cargo run -- status
cargo run -- verify
```

### SSH ke Codespace
```bash
# Via orchestrator state
gh codespace ssh -c mawari-node-xxxxx

# Atau list dulu
gh codespace list
gh codespace ssh -c <name>
```

### Cek Mawari Node
```bash
# Cek docker container
docker ps

# Cek logs real-time
docker logs -f mawari-node

# Cek burner wallet yang dipakai
cat ~/mawari/mawari_data/flohive-cache.json
```

### Cek Nexus Node
```bash
# List tmux sessions
tmux ls

# Attach ke session
tmux attach -t nexus
# Detach: Ctrl+B lalu D

# Cek status
nexus-cli status
```

---

## 🔧 Troubleshooting

### Node tidak jalan setelah codespace dibuat?
Tunggu 2-3 menit untuk `postCreateCommand` selesai. Cek log:
```bash
cat /workspaces/mawari-nexus-blueprint/setup.log
cat /workspaces/mawari-nexus-blueprint/autostart.log
```

### Mawari container tidak jalan?
```bash
# Cek docker
docker ps -a

# Cek logs
docker logs mawari-node

# Restart manual
bash /workspaces/mawari-nexus-blueprint/auto-start.sh
```

### Nexus tidak jalan?
```bash
# Cek tmux
tmux ls

# Restart manual
bash /workspaces/mawari-nexus-blueprint/auto-start.sh
```

### Secret tidak terdeteksi?
- Pastikan secret di-set di **Codespace secrets** (bukan Repository secrets)
- Recreate codespace setelah update secrets
- Cek: `echo $MAWARI_OWNER_ADDRESS` di dalam codespace

### Error "Cache file missing"?
`first-setup.sh` belum jalan atau gagal. Cek:
```bash
cat /workspaces/mawari-nexus-blueprint/setup.log
ls -la ~/mawari/mawari_data/
```

---

## 📁 File Structure

```
.
├── .devcontainer/
│   └── devcontainer.json    # Config codespace
├── first-setup.sh            # First-time setup (buat folder, install CLI)
├── auto-start.sh             # Auto-start node (docker/tmux)
├── .gitignore                # Ignore rules
└── README.md                 # Documentation
```

---

## ⚙️ Technical Details

### Codespace Lifecycle

**1. Create (postCreateCommand):**
- Install dependencies (tmux, screen, curl, wget, jq)
- Run `first-setup.sh`:
  - Mawari: Create `~/mawari/mawari_data/flohive-cache.json` dengan burner wallet
  - Nexus: Install Nexus CLI + tmux
- Run `auto-start.sh`:
  - Mawari: Start Docker container dengan volume mount
  - Nexus: Register user + start dalam tmux session

**2. Start/Resume (postStartCommand):**
- Run `auto-start.sh` untuk restart node jika stopped

**3. Auto-Restart Logic:**
- Mawari: Check `docker ps`, jika tidak ada container → start baru
- Nexus: Check `tmux ls`, jika tidak ada session → start baru

### Node Detection
Script auto-detect dari `$CODESPACE_NAME`:
- Nama mengandung `mawari` → Setup Mawari
- Nama mengandung `nexus` → Setup Nexus

### Machine Types
- **basicLinux32gb**: 2-core, 8GB RAM, 32GB storage (Mawari)
- **standardLinux32gb**: 4-core, 16GB RAM, 32GB storage (Nexus)

### Timeouts
- **Idle**: 240 menit (4 jam)
- **Retention**: 24 jam setelah shutdown
- **Orchestrator cycle**: 20 jam per account

---

## 🔐 Security Notes

- **Burner wallet**: Gunakan wallet terpisah khusus untuk Mawari, JANGAN wallet utama
- **Private key**: Disimpan di Codespace secrets (encrypted at rest)
- **Auto-cleanup**: Codespace auto-delete setelah 24 jam shutdown
- **Token rotation**: Orchestrator otomatis ganti akun setiap 20 jam

---

## 🎯 Orchestrator Strategy

**Nuke & Create:**
1. Check existing codespaces di repo
2. Stop & delete semua codespace lama
3. Create 2 codespace baru (mawari + nexus)
4. Wait verification (max 3x @ 20s)
5. Run 20 jam
6. Switch to next token
7. Repeat

**Benefit:**
- Clean state setiap cycle
- Avoid idle timeout billing
- Maximize free tier usage

---

## 📞 Support

**Codespace Issues:**
- Check logs di `/workspaces/mawari-nexus-blueprint/*.log`
- Verify secrets: `echo $MAWARI_OWNER_ADDRESS`
- Manual trigger: `bash auto-start.sh`

**Orchestrator Issues:**
- Check state: `cargo run -- status`
- Verify nodes: `cargo run -- verify`
- Reset state: `del state.json`

---

## ✅ Quick Checklist

- [ ] 5 secrets configured di GitHub Codespace settings
- [ ] Burner wallet generated (jangan pakai wallet utama!)
- [ ] Nexus Node ID didapat dari dashboard
- [ ] Orchestrator tokens.json filled
- [ ] Repository pushed to GitHub
- [ ] Test run: `.\start-otak.bat USERNAME/mawari-nexus-blueprint`

---

**Ready to earn! 🚀**
