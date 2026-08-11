#!/bin/sh
# Diagnostic + reparation de l'acces SSH par cle. A lancer en root.
KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxSBGZ0r+7zX1B/IJCKFGCFdYDX9Uqmc9bJWfxbI0YY grandline-vps"

echo "===== reglages sshd ====="
sshd -T 2>/dev/null | grep -iE "authorizedkeysfile|allowusers|allowgroups|denyusers|permitrootlogin|pubkeyauthentication|strictmodes"

echo "===== droits ====="
ls -ld /home/alterax /home/alterax/.ssh /home/alterax/.ssh/authorized_keys 2>&1

echo "===== derniers refus (auth.log) ====="
grep -iE "denied|refused|bad ownership|Failed publickey" /var/log/auth.log 2>/dev/null | tail -5

echo "===== reparations ====="
chmod 755 /home/alterax 2>/dev/null && echo "home 755"
chown -R alterax:alterax /home/alterax/.ssh 2>/dev/null && echo "proprietaire .ssh OK"
chmod 700 /home/alterax/.ssh 2>/dev/null
chmod 600 /home/alterax/.ssh/authorized_keys 2>/dev/null && echo "droits cles OK"

AKF=$(sshd -T 2>/dev/null | awk 'tolower($1)=="authorizedkeysfile"{print $2}')
echo "emplacement des cles selon sshd . $AKF"
case "$AKF" in
  /*)
    f=$(echo "$AKF" | sed "s/%u/alterax/")
    mkdir -p "$(dirname "$f")"
    touch "$f"
    grep -qF "$KEY" "$f" || echo "$KEY" >> "$f"
    chmod 644 "$f"
    echo "cle aussi posee dans $f"
    ;;
esac
echo "===== FIN ====="
