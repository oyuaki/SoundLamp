#!/usr/bin/env bash
# Builds a universal Release SoundLamp.app, ad-hoc signs it, and packages dist/*.zip and dist/*.dmg.
# Usage: scripts/package.sh [version]   (e.g. scripts/package.sh 1.2.0)
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${1:-$(grep -m1 'MARKETING_VERSION' project.yml | sed -E 's/.*"(.*)".*/\1/')}"
BUILD_DIR="build"
DIST_DIR="dist"
APP="$BUILD_DIR/Build/Products/Release/SoundLamp.app"

xcodegen generate

xcodebuild \
  -project SoundLamp.xcodeproj \
  -scheme SoundLamp \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -derivedDataPath "$BUILD_DIR" \
  ARCHS="arm64 x86_64" \
  ONLY_ACTIVE_ARCH=NO \
  MARKETING_VERSION="$VERSION" \
  CODE_SIGN_IDENTITY="-" \
  build

# Re-sign ad-hoc so the bundle seal covers everything.
codesign --force --deep --options runtime --sign - "$APP"
codesign --verify --deep --strict "$APP"
lipo -info "$APP/Contents/MacOS/SoundLamp"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

ditto -c -k --keepParent "$APP" "$DIST_DIR/SoundLamp-$VERSION.zip"

STAGING="$(mktemp -d)"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname "SoundLamp" -srcfolder "$STAGING" -ov -format UDZO "$DIST_DIR/SoundLamp-$VERSION.dmg"
rm -rf "$STAGING"

ls -lh "$DIST_DIR"
