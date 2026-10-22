#!/bin/bash
set -euo pipefail

# === KONFIGURASI ===
KEY_FILE="$HOME/.gsocket-secret"
GS_DIR="$HOME/.local/share/gsocket"
# ===================

mkdir -p "$GS_DIR"

if [ ! -f "$KEY_FILE" ]; then
  SECRET=$(head -c 32 /dev/urandom | base64 | tr -d -c 'a-zA-Z0-9' | head -c 22)
  echo "$SECRET" > "$KEY_FILE"
  chmod 600 "$KEY_FILE"
  echo "[+] Secret baru: $KEY_FILE"
else
  SECRET=$(cat "$KEY_FILE")
  echo "[+] Pakai secret: $KEY_FILE"
fi

echo "[+] Install GSocket (user-level)..."
X="$SECRET" GS_DSTDIR="$GS_DIR" bash -c "$(curl -fsSL https://gsocket.io/y)"

echo "[+] Selesai."
echo "[+] Secret: $SECRET"
echo "[+] Connect: gs-netcat -s '$SECRET' -i"
