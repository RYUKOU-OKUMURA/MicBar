#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
INSTALL_PATH="/Applications/MicBar.app"

echo "==> Quitting MicBar..."
pkill -x MicBar >/dev/null 2>&1 || true
sleep 0.5

echo "==> Removing legacy DerivedData copies..."
find "${HOME}/Library/Developer/Xcode/DerivedData" -path "*/Build/Products/*/MicBar.app" -print0 2>/dev/null \
  | xargs -0 rm -rf 2>/dev/null || true

echo "==> Unregistering all MicBar.app paths..."
"$LSREGISTER" -dump 2>/dev/null | rg "path:.*MicBar\.app" | sed 's/.*path:[[:space:]]*\(.*\) (.*/\1/' | while read -r app_path; do
  [[ -d "$app_path" ]] && "$LSREGISTER" -u "$app_path" >/dev/null 2>&1 || true
done

echo "==> Building MicBar (output: ${INSTALL_PATH})..."
cd "$ROOT"
xcodegen generate >/dev/null
xcodebuild -scheme MicBar -configuration Debug build -quiet

if [[ ! -d "$INSTALL_PATH" ]]; then
  echo "error: ${INSTALL_PATH} was not created" >&2
  exit 1
fi

touch "$INSTALL_PATH"
"$LSREGISTER" -f -R -trusted "$INSTALL_PATH"

echo "==> Removing DerivedData copies again..."
find "${HOME}/Library/Developer/Xcode/DerivedData" -path "*/Build/Products/*/MicBar.app" -print0 2>/dev/null \
  | xargs -0 rm -rf 2>/dev/null || true

echo "==> Re-indexing Spotlight for MicBar..."
mdimport "$INSTALL_PATH" >/dev/null 2>&1 || true

echo "==> Resetting Launchpad cache..."
defaults write com.apple.dock ResetLaunchPad -bool true
killall Dock >/dev/null 2>&1 || true
sleep 2

echo ""
echo "=== Verification ==="
echo "On disk:"
mdfind "kMDItemFSName == 'MicBar.app'" 2>/dev/null || true
echo "Launch Services:"
"$LSREGISTER" -dump 2>/dev/null | rg "path:.*MicBar\.app" || echo "  (none)"

echo ""
open -a "$INSTALL_PATH"
echo "Done. Only ${INSTALL_PATH} should appear in Launchpad."
