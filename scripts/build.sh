#!/bin/bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
COMMIT=c37cf6cb42279ce9648ff7314180c866d68f9e0d
for cmd in git meson ninja pkg-config perl flex python3; do command -v "$cmd" >/dev/null || { echo "Missing dependency: $cmd" >&2; exit 1; }; done
[[ $(uname -s) == Darwin && $(uname -m) == arm64 ]] || { echo 'Requires macOS on Apple Silicon.' >&2; exit 1; }
pkg-config --exists libusb-1.0 || { echo 'Missing libusb-1.0 (brew install libusb).' >&2; exit 1; }
WORK=$(mktemp -d "${TMPDIR:-/tmp}/cns-ccid-build.XXXXXXXX")
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$ROOT/dist"
git clone -q --no-checkout https://github.com/LudovicRousseau/CCID.git "$WORK/src"
git -C "$WORK/src" checkout -q --detach "$COMMIT"
[[ $(git -C "$WORK/src" rev-parse HEAD) == "$COMMIT" ]]
export MACOSX_DEPLOYMENT_TARGET=14.0
export PKG_CONFIG_PATH="$WORK/src/MacOSX${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
export CFLAGS="${CFLAGS:-} -DRESPONSECODE_DEFINED_IN_WINTYPES_H -I$WORK/src/MacOSX"
meson setup "$WORK/build" "$WORK/src" -Dpcsclite=false -Dos_log=true -Dclass=false -Dcomposite-as-multislot=true -Dextra_bundle_id=cns-test -Dudev-rules=false
meson compile -C "$WORK/build"
DESTDIR="$WORK/stage" meson install -C "$WORK/build"
BUNDLE="$WORK/stage/usr/local/libexec/SmartCardServices/drivers/ifd-ccid-cns-test.bundle"
[[ -f "$BUNDLE/Contents/MacOS/libccid.dylib" ]]
python3 - "$BUNDLE/Contents/Info.plist" <<'PY'
import plistlib,sys
path=sys.argv[1]
with open(path,'rb') as f: d=plistlib.load(f)
keys=('ifdVendorID','ifdProductID','ifdFriendlyName')
assert len({len(d[k]) for k in keys}) == 1
matches=[i for i,(v,p) in enumerate(zip(d[keys[0]],d[keys[1]])) if int(v,16)==0x058f and int(p,16)==0x9540]
assert len(matches)==1, 'Expected exactly one Alcor AU9540 entry'
for key in keys: d[key]=[d[key][matches[0]]]
with open(path,'wb') as f: plistlib.dump(d,f)
PY
rm -rf "$ROOT/dist/ifd-ccid-cns-test.bundle"
ditto "$BUNDLE" "$ROOT/dist/ifd-ccid-cns-test.bundle"
cp "$WORK/src/COPYING" "$ROOT/dist/CCID-LICENSE.txt"
printf 'Driver built at %s\n' "$ROOT/dist/ifd-ccid-cns-test.bundle"
shasum -a 256 "$ROOT/dist/ifd-ccid-cns-test.bundle/Contents/MacOS/libccid.dylib"
