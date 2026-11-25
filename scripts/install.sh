#!/bin/bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC="$ROOT/dist/ifd-ccid-cns-test.bundle"
DST=/usr/local/libexec/SmartCardServices/drivers/ifd-ccid-cns-test.bundle
STATE=/var/db/cns-ccid-test/previous
[[ $(uname -s) == Darwin && $(uname -m) == arm64 ]] || { echo 'Requires macOS on Apple Silicon.' >&2; exit 1; }
OS=$(sw_vers -productVersion | cut -d. -f1)
case "$OS" in 14|15|26|27) ;; *) echo "macOS $OS is outside the intended test range." >&2; exit 1 ;; esac
[[ -d "$SRC" ]] || { echo 'Build the driver first: ./scripts/build.sh' >&2; exit 1; }
[[ ! -e "$DST" ]] || { echo 'A driver with this name already exists; no changes made.' >&2; exit 1; }
[[ ! -e "$STATE" ]] || { echo 'Existing rollback state found; no changes made.' >&2; exit 1; }
python3 - "$SRC/Contents/Info.plist" <<'PY'
import plistlib,sys
with open(sys.argv[1],'rb') as f: d=plistlib.load(f)
assert d['ifdVendorID']==['0x058F'] and d['ifdProductID']==['0x9540'], 'Unexpected reader list'
PY
file "$SRC/Contents/MacOS/libccid.dylib" | grep -q arm64 || { echo 'Driver is not arm64.' >&2; exit 1; }
echo 'This installs a locally built, non-notarized driver and changes useIFDCCID for all smart-card readers.'
echo 'macOS 26.6.2 was tested; macOS 27 success was user reported. macOS 14 and 15 have no hardware tests yet.'
read -r -p 'Continue? Type YES: ' answer
[[ "$answer" == YES ]] || { echo 'Cancelled.'; exit 1; }
sudo -v
sudo mkdir -p /var/db/cns-ccid-test
previous=$(defaults read /Library/Preferences/com.apple.security.smartcard useIFDCCID 2>/dev/null || printf absent)
case "$previous" in 0|1|absent) ;; *) echo 'Unsupported existing preference; no changes made.' >&2; exit 1 ;; esac
printf '%s\n' "$previous" | sudo tee "$STATE" >/dev/null
sudo chmod 600 "$STATE"
if ! sudo ditto "$SRC" "$DST" || ! sudo chown -R root:wheel "$DST" || ! sudo defaults write /Library/Preferences/com.apple.security.smartcard useIFDCCID -bool yes; then
  echo 'Installation incomplete. Run ./scripts/uninstall.sh to restore.' >&2; exit 1
fi
echo 'Installed. Unplug and reconnect the reader; verify it and test your CNS.'
