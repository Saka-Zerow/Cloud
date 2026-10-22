#!/bin/bash
set -uo pipefail

# === KONFIGURASI ===
KEY_FILE="$HOME/.gsocket-secret"
GS_DIR="$HOME/.local/share/gsocket"
LOG="$HOME/gs-install.log"
PORTS="443 53 80 22"
# ===================

log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }

# 1. Rotate secret kalau belum ada
if [ ! -f "$KEY_FILE" ]; then
  SECRET=$(head -c 48 /dev/urandom | base64 | tr -d -c 'a-zA-Z0-9' | head -c 32)
  echo "$SECRET" > "$KEY_FILE"
  chmod 600 "$KEY_FILE"
  log "[+] Secret baru (32 char): $KEY_FILE"
else
  SECRET=$(cat "$KEY_FILE")
  log "[+] Pakai secret existing: $KEY_FILE"
fi

mkdir -p "$GS_DIR"

# 2. Coba install dengan port fallback
INSTALL_OK=0
for PORT in $PORTS; do
  log "[*] Coba port $PORT..."
  if X="$SECRET" GS_DSTDIR="$GS_DIR" GS_PORT="$PORT" \
     timeout 120 bash -c "$(curl -fsSL https://gsocket.io/y)" >>"$LOG" 2>&1; then
    log "[+] Install sukses di port $PORT"
    INSTALL_OK=1
    echo "$PORT" > "$HOME/.gsocket-port"
    break
  else
    log "[!] Port $PORT gagal, coba berikutnya..."
  fi
done

if [ "$INSTALL_OK" -eq 0 ]; then
  log "[x] Semua port gagal. Cek koneksi keluar VPS."
  exit 1
fi

# 3. Verifikasi binary
if [ -x "$GS_DIR/gs-netcat" ]; then
  log "[+] Binary OK: $GS_DIR/gs-netcat"
else
  log "[!] Binary tidak ditemukan di $GS_DIR, cari manual:"
  find "$HOME" -name "gs-netcat" -type f 2>/dev/null | tee -a "$LOG"
fi

# 4. Tampilkan ringkasan
PORT=$(cat "$HOME/.gsocket-port")
log ""
log "========================================="
log " INSTALASI SELESAI"
log "========================================="
log " Secret : $SECRET"
log " Port   : $PORT"
log " Binary : $GS_DIR/gs-netcat"
log ""
log " Connect dari laptop:"
log "   S='$SECRET' bash -c \"\$(curl -fsSL https://gsocket.io/y)\""
log "   # atau kalau sudah punya gs-netcat:"
log "   gs-netcat -s '$SECRET' -i"
log ""
log " Persist setelah reboot (cron):"
log "   crontab -e"
log "   tambahkan:"
log "   @reboot $GS_DIR/gs-netcat -ilD -s \$(cat $KEY_FILE) -p $PORT"
log "========================================="

