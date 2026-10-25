#!/usr/bin/env bash
# Install DualSense Expressive desktop launcher and application icon

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICON_SRC="$DIR/resources/icons/app-icon.svg"
ICON_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"
DESKTOP_DIR="$HOME/.local/share/applications"

mkdir -p "$ICON_DIR"
mkdir -p "$DESKTOP_DIR"

# Ensure binary is built
if [ ! -f "$DIR/build/dualsense-expressive" ]; then
    echo "🔨 Building DualSense Expressive..."
    "$DIR/scripts/build.sh"
fi

# Copy App Icon
cp "$ICON_SRC" "$ICON_DIR/io.github.x_eon_max.dualsense_expressive.svg"
cp "$ICON_SRC" "$ICON_DIR/dualsensectl-gui.svg"

# Install Desktop Entry
sed "s|Exec=dualsense-expressive|Exec=$DIR/build/dualsense-expressive|g" \
    "$DIR/io.github.x_eon_max.dualsense_expressive.desktop" > "$DESKTOP_DIR/io.github.x_eon_max.dualsense_expressive.desktop"

chmod +x "$DESKTOP_DIR/io.github.x_eon_max.dualsense_expressive.desktop"
update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

echo "✓ Successfully installed DualSense Expressive to $DESKTOP_DIR/io.github.x_eon_max.dualsense_expressive.desktop"
echo "You can now launch 'DualSense Expressive' directly from your application launcher!"
