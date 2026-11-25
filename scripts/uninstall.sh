#!/bin/bash
set -euo pipefail
DST=/usr/local/libexec/SmartCardServices/drivers/ifd-ccid-cns-test.bundle
STATE=/var/db/cns-ccid-test/previous
[[ -e "$STATE" ]] || { echo 'No saved previous preference; nothing changed.' >&2; exit 1; }
sudo -v
previous=$(sudo cat "$STATE")
case "$previous" in
 absent) sudo defaults delete /Library/Preferences/com.apple.security.smartcard useIFDCCID 2>/dev/null || true ;;
 1) sudo defaults write /Library/Preferences/com.apple.security.smartcard useIFDCCID -bool yes ;;
 0) sudo defaults write /Library/Preferences/com.apple.security.smartcard useIFDCCID -bool no ;;
 *) echo 'Unrecognized saved preference; nothing changed.' >&2; exit 1 ;;
esac
sudo rm -rf "$DST"
sudo rm -f "$STATE"
echo 'Restored. Unplug and reconnect the reader.'
