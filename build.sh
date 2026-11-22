#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

# Build each architecture separately, then merge into a universal binary.
BINS=()
for ARCH in arm64 x86_64; do
    swift build -c release --triple "$ARCH-apple-macosx13.0"
    BINS+=("$(swift build -c release --triple "$ARCH-apple-macosx13.0" --show-bin-path)/LangPerApp")
done

APP=build/LangPerApp.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
lipo -create "${BINS[@]}" -output "$APP/Contents/MacOS/LangPerApp"
cp Resources/Info.plist "$APP/Contents/Info.plist"
codesign --force --sign - "$APP"
echo "Built $APP"

rm -f build/LangPerApp.zip
ditto -c -k --keepParent "$APP" build/LangPerApp.zip
echo "Built build/LangPerApp.zip"
