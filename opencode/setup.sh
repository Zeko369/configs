#!/bin/bash
# Setup opencode plugins and hooks
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing opencode dependencies..."
cd "$SCRIPT_DIR"
bun install

echo "Installing opencode-wakatime hook..."
bunx opencode-wakatime --install

echo "Done!"
