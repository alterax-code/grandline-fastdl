#!/bin/sh
# Autorise la cle SSH du poste de dev (cle PUBLIQUE) pour alterax et root.
# Idempotent : relancer ne duplique rien, n'ecrase rien.
set -e
KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxSBGZ0r+7zX1B/IJCKFGCFdYDX9Uqmc9bJWfxbI0YY grandline-vps"
for u in alterax root; do
  home=$(getent passwd "$u" | cut -d: -f6)
  [ -n "$home" ] || continue
  mkdir -p "$home/.ssh"
  touch "$home/.ssh/authorized_keys"
  grep -qF "$KEY" "$home/.ssh/authorized_keys" || echo "$KEY" >> "$home/.ssh/authorized_keys"
  chmod 700 "$home/.ssh"
  chmod 600 "$home/.ssh/authorized_keys"
  chown -R "$u" "$home/.ssh" 2>/dev/null || true
  echo "OK $u"
done
