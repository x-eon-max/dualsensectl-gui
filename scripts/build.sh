#!/usr/bin/env bash
# Build script for DualSense Expressive (C++20 / Qt6 QML)

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$DIR/build"

echo "🎮 Building DualSense Expressive (Material 3 Expressive)..."

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -j"$(nproc)"

# Create root symlinks for convenience
ln -sf "$BUILD_DIR/dualsense-expressive" "$DIR/dualsense-expressive"
ln -sf "$BUILD_DIR/dualsense-expressive" "$DIR/dualsensectl-gui"

echo ""
echo "✨ Build completed successfully!"
echo "Binary created: $BUILD_DIR/dualsense-expressive"
echo "Run with: ./scripts/run.sh or ./dualsense-expressive"
