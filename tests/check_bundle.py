#!/usr/bin/env python3
import plistlib, sys
from pathlib import Path
p = Path(sys.argv[1])
with (p / 'Contents/Info.plist').open('rb') as f:
    d = plistlib.load(f)
assert d['ifdVendorID'] == ['0x058F']
assert d['ifdProductID'] == ['0x9540']
assert d['CFBundleShortVersionString'] == '1.8.4'
assert (p / 'Contents/MacOS/libccid.dylib').is_file()
print('Bundle manifest OK: Alcor AU9540 only')
