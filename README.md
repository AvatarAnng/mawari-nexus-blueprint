# 📁 Complete Setup Guide - Folder Structure

## 🎯 Tujuan
Memisahkan orchestrator (kontrol) dari repository GitHub (runtime). Orchestrator berjalan di laptop, repository di-push ke GitHub.

---

## 📂 Struktur Lengkap

```
D:\SC\
│
├── codespace-orchestrator\          ← ORCHESTRATOR (LOKAL - JANGAN PUSH)
│   ├── src\
│   │   ├── main.rs                  ← Entry point
│   │   ├── config.rs                ← Load tokens & state
│   │   └── github.rs                ← GitHub API wrapper
│   │
│   ├── Cargo.toml                   ← Rust dependencies
│   ├── Cargo.lock                   ← Auto-generated
│   │
│   ├── tokens.json                  ← ⚠️ RAHASIA - JANGAN COMMIT!
│   ├── state.json                   ← Auto-generated saat running
│   │
│   ├── start-otak.bat               ← Launcher
│   ├── check-status.bat             ← Status checker
│   ├── nuke-all.bat                 ← Emergency cleanup
│   └── build.bat                    ← Build helper
│
└── mawari-nexus-blueprint\          ← REPOSITORY (PUSH KE GITHUB)
    ├── .devcontainer\
    │   └── devcontainer.json        ← Codespace config
    │
    ├── start.sh                     ← Setup script (auto-run)
    ├── .gitignore                   ← Ignore rules
    └── README.md                    ← Documentation
```

---

## 🛠️ Step-by-Step Setup

### STEP 1: Buat Folder Structure

```powershell
# Buat folder utama
mkdir D:\SC
cd D:\SC

# Buat orchestrator folder
mkdir codespace-orchestrator
cd codespace-orchestrator
mkdir src

# Kembali ke root
cd ..

# Clone atau buat repo folder
git clone https://github.com/username/mawari-nexus-blueprint.git
# atau
mkdir mawari-nexus-blueprint
cd mawari-nexus-blueprint
git init
```

---

### STEP 2: Setup Orchestrator

#### 2.1 Buat File Rust

**File: `src/main.rs`**
```rust
// Copy dari artifact: full_main_rs
```

**File: `src/config.rs`**
```rust
// Copy dari artifact: full_config_rs
```

**File: `src/github.rs`**
```rust
// Copy dari artifact: full_github_rs
```

#### 2.2 Buat Cargo.toml

**File: `Cargo.toml`**
```toml
// Copy dari artifact: clean_cargo_toml
```

#### 2.3 Buat tokens.json

**File: `tokens.json`** (RAHASIA!)
```json
{
  "tokens": [
    "ghp_YourActualTokenHere1",
    "ghp_YourActualTokenHere2",
    "ghp_YourActualTokenHere3"
  ]
}
```

> ⚠️ **CRITICAL**: File ini TIDAK BOLEH di-commit ke GitHub!

#### 2.4 Buat Batch Scripts

**File: `start-otak.bat`**
```batch
@echo off
cd /d D:\SC\codespace-orchestrator
cargo run --release -- %1
```

**File: `check-status.bat`**
```batch
@echo off
echo Checking orchestrator status...
if exist state.json (
    echo Current State:
    type state.json
) else (
    echo No state file found
)
gh cs list
pause
```

**File: `build.bat`**
```batch
@echo off
cargo build --release
echo Build complete!
pause
```

#### 2.5 Build Orchestrator

```powershell
cd D:\SC\codespace-orchestrator
cargo build --release
```

Output:
```
   Compiling orchestrator v0.2.0
    Finished release [optimized] target(s) in 12.34s
```

---

### STEP 3: Setup Repository

#### 3.1 Buat Folder Structure

```bash
cd D:\SC\mawari-nexus-blueprint
mkdir .devcontainer
```

#### 3.2 Buat Files

**File: `.devcontainer/devcontainer.json`**
```json
// Copy dari artifact: clean_devcontainer
```

**File: `start.sh`**
```bash
// Copy dari artifact: clean_start_sh
```

**File: `.gitignore`**
```
// Copy dari artifact: clean_gitignore
```

**File: `README.md`**
```markdown
# Mawari & Nexus Node Blueprint

Automated setup untuk Mawari dan Nexus node di GitHub Codespaces.

## Setup

1. Fork repository ini
2. Set Codespace secrets:
   - MAWARI_OWNER_ADDRESS
   - NEXUS_WALLET_ADDRESS
   - NEXUS_NODE_ID
3. Codespace akan auto-setup saat dibuat

## Kontrol

Semua kontrol dilakukan via orchestrator di laptop lokal.
Lihat dokumentasi lengkap di SETUP-GUIDE.md
```

#### 3.3 Set Executable Permission

```bash
chmod +x start.sh
```

#### 3.4 Commit & Push

```bash
git add .
git commit -m "Initial setup - automated node deployment"
git push origin main
```

---

### STEP 4: Setup GitHub Repository Secrets

1. Buka: https://github.com/username/mawari-nexus-blueprint/settings/secrets/codespaces
2. Klik "New repository secret"
3. Tambahkan 3 secrets:

```
Name: MAWARI_OWNER_ADDRESS
Value: 0xYourEthereumAddress

Name: NEXUS_WALLET_ADDRESS
Value: 0xYourEthereumAddress

Name: NEXUS_NODE_ID
Value: your-nexus-node-id-from-registration
```

---

### STEP 5: Generate GitHub Tokens

#### 5.1 Generate Token

1. Buka: https://github.com/settings/tokens
2. Klik "Generate new token (classic)"
3. Set permissions:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `codespace` (Full control of codespaces)
4. Set expiration: 90 days
5. Generate token
6. Copy token (ghp_...)

#### 5.2 Update tokens.json

```json
{
  "tokens": [
    "ghp_TokenDariAkun1",
    "ghp_TokenDariAkun2",
    "ghp_TokenDariAkun3"
  ]
}
```

> **Tips**: Generate token dari multiple GitHub accounts untuk load balancing

---

## 🚀 Cara Menjalankan

### First Run

```bash
cd D:\SC\codespace-orchestrator
start-otak.bat username/mawari-nexus-blueprint
```

### Output Expected

```
╔════════════════════════════════════════════════╗
║   ORCHESTRATOR CODESPACE - KONTROL PENUH      ║
╚════════════════════════════════════════════════╝

📂 Membaca konfigurasi dari tokens.json...
✅ Berhasil load 3 token
🎯 Target Repo: username/mawari-nexus-blueprint
🆕 Memulai siklus baru dari awal

🔄 Memulai loop otomatis...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔐 Mencoba Token #1 dari 3
✅ Token VALID untuk akun: @username1
🚀 Memulai siklus deployment...

  🔍 Scanning codespace yang ada...
  ✅ Tidak ada codespace lama. Parkiran bersih.

  🏗️  Membangun codespace baru...
    1️⃣  Membuat mawari-node (basicLinux32gb)...
       ✅ Mawari: vigilant-space-bassoon-abc123
    2️⃣  Membuat nexus-node (standardLinux32gb)...
       ✅ Nexus: improved-fortnight-xyz789

╔════════════════════════════════════════════════╗
║         DEPLOYMENT BERHASIL!                   ║
╚════════════════════════════════════════════════╝
👤 Akun        : @username1
🌐 Mawari Node : vigilant-space-bassoon-abc123
🔷 Nexus Node  : improved-fortnight-xyz789
💾 State tersimpan ke state.json

⏰ Timer dimulai: 20 jam
💤 Akun @username1 akan berjalan hingga selesai...
```

---

## 🔍 Verifikasi Setup

### 1. Cek Codespace di GitHub

```bash
gh cs list
```

Output:
```
NAME                              REPOSITORY                          BRANCH  STATE
vigilant-space-bassoon-abc123     username/mawari-nexus-blueprint     main    Available
improved-fortnight-xyz789         username/mawari-nexus-blueprint     main    Available
```

### 2. SSH ke Codespace

```bash
gh cs ssh -c vigilant-space-bassoon-abc123
```

### 3. Cek Node Status

```bash
# List tmux sessions
tmux list-sessions

# Output:
# mawari: 1 windows (created ...)
# nexus: 1 windows (created ...)

# Attach ke mawari
tmux attach -t mawari

# Attach ke nexus
tmux attach -t nexus

# Keluar: Ctrl+B lalu D
```

### 4. Cek Docker

```bash
docker ps

# Output:
# CONTAINER ID   IMAGE         STATUS          NAMES
# abc123...      mawari-node   Up 5 minutes    mawari-node
```

### 5. Cek Log

```bash
cat /workspaces/mawari-nexus-blueprint/startup.log
```

---

## 📊 File Yang Harus/Tidak Boleh Di-Commit

### ✅ AMAN untuk di-commit (Repository):
- `.devcontainer/devcontainer.json`
- `start.sh`
- `.gitignore`
- `README.md`
- Dokumentasi

### ❌ JANGAN COMMIT (Orchestrator):
- `tokens.json` ← RAHASIA!
- `state.json` ← Auto-generated
- Semua file di folder `codespace-orchestrator/`
- `target/` ← Rust build artifacts

---

## 🎯 Summary

| Component | Location | Git Status |
|-----------|----------|------------|
| Orchestrator | `D:\SC\codespace-orchestrator\` | ❌ Lokal only |
| Repository | `D:\SC\mawari-nexus-blueprint\` | ✅ Push to GitHub |
| Tokens | `orchestrator/tokens.json` | ❌ RAHASIA |
| State | `orchestrator/state.json` | ❌ Auto-generated |
| Scripts | `repository/*.sh` | ✅ Safe to commit |

---

## 🎉 Setup Complete!

Struktur folder sudah benar. Orchestrator terpisah dari repository. 

**Next Steps:**
1. Generate GitHub tokens
2. Update tokens.json
3. Set repository secrets
4. Run: `start-otak.bat username/repo-name`

Happy automating! 🚀
