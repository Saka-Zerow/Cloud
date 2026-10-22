#!/bin/bash
set -euo pipefail

# === KONFIGURASI ===
KEY_FILE="/root/.gsocket-secret"
# ===================

# Generate secret acak kalau belum ada
if [ ! -f "$KEY_FILE" ]; then
  SECRET=$(head -c 32 /dev/urandom | base64 | tr -d -c 'a-zA-Z0-9' | head -c 22)
  echo "$SECRET" > "$KEY_FILE"
  chmod 600 "$KEY_FILE"
  echo "[+] Secret baru dibuat: $KEY_FILE"
else
  SECRET=$(cat "$KEY_FILE")
  echo "[+] Pakai secret yang sudah ada: $KEY_FILE"
fi

# Install GSocket dengan secret tersebut (persist, autostart)
echo "[+] Install GSocket..."
X="$SECRET" bash -c "$(curl -fsSL https://gsocket.io/y)"

echo "[+] Selesai."
echo "[+] Secret kamu: $(cat $KEY_FILE)"
echo "[+] Simpan secret ini di tempat aman (password manager)."
echo "[+] Untuk connect dari laptop:"
echo "    S='$SECRET' bash -c \"\$(curl -fsSL https://gsocket.io/y)\""
echo "[+] Atau: gs-netcat -s '$SECRET' -i"
