#!/usr/bin/env bash
# Reinstall the music_theory CLI globally after making changes.
#
# Usage: ./scripts/reinstall.sh
#
# This script:
# 1. Runs tests to ensure everything works
# 2. Deactivates the old version
# 3. Clears any cached snapshot files
# 4. Activates the new version from source

set -e

cd "$(dirname "$0")/.."

echo "Running tests..."
dart test

echo ""
echo "Analyzing..."
dart analyze

echo ""
echo "Clearing cached snapshots..."
rm -rf .dart_tool/pub/bin/

echo ""
echo "Reinstalling globally..."
dart pub global deactivate music_theory 2>/dev/null || true
dart pub global activate --source path .

echo ""
echo "Done! Try: music_theory --help"
