#!/usr/bin/env bash
# Until Then setup helper for a fresh Debian/Ubuntu KVM VM.
# Installs desktop access, Wine, and graphics tools.
# Does NOT download game/torrent files; use your own legitimate game copy.

set -Eeuo pipefail
LOG="/var/log/until-then-kvm-setup.log"
exec > >(tee -a "$LOG") 2>&1
trap 'echo; echo "Setup stopped at line $LINENO. Check $LOG"; exit 1' ERR

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash $0"
  exit 1
fi

. /etc/os-release
if [[ "${ID:-}" != "debian" && "${ID:-}" != "ubuntu" ]]; then
  echo "Supported systems: Debian or Ubuntu."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates curl wget dbus-x11 xauth x11-xserver-utils \
  xfce4 xfce4-terminal xserver-xorg-core xserver-xorg-video-dummy xinit \
  xrdp mesa-utils mesa-vulkan-drivers vulkan-tools \
  wine wine64 winbind fonts-liberation fonts-noto-core \
  unzip p7zip-full procps lsof

echo "Enabling XRDP desktop access..."
systemctl enable --now xrdp || true

cat <<'INFO'

============================================================
BASE SETUP COMPLETE
============================================================

This installed XFCE desktop, XRDP, Wine, and graphics diagnostic tools.
It did NOT install Until Then or download any torrent/game files.

NEXT STEPS
1. Connect to the VM using Remote Desktop (RDP) at the VM's IP, port 3389.
2. Log in with a normal Linux user, not root.
3. If needed, allow TCP 3389 in the VM firewall/provider firewall.
   Safer option: restrict RDP to your IP or use a VPN; don't expose it publicly.
4. For best compatibility, install the official Linux version of Until Then
   through Steam using your own account and game license.
5. Alternatively, copy your own legally obtained Windows game files to the VM
   and test with:
     WINEPREFIX="$HOME/.wine-until-then" wine "/path/to/UntilThen.exe"

GRAPHICS WARNING
A KVM VM without GPU passthrough may use software rendering, which can be
very slow or may not run the game. This script does not configure GPU passthrough,
Cloudflare Tunnel, or browser-based game streaming. It provides a basic desktop
so you can test the VM first.

Setup log: /var/log/until-then-kvm-setup.log
============================================================
INFO
