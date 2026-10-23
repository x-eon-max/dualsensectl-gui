#!/usr/bin/env bash
# Install dualsensectl-gui desktop launcher and application icon

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICON_SRC="$DIR/dualsensectl_gui/resources/dualsense.svg"
ICON_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"
DESKTOP_DIR="$HOME/.local/share/applications"

mkdir -p "$ICON_DIR"
mkdir -p "$DESKTOP_DIR"

# Copy Icon
cp "$ICON_SRC" "$ICON_DIR/dualsensectl-gui.svg"

# Create Desktop Entry
cat <<EOF > "$DESKTOP_DIR/dualsensectl-gui.desktop"
[Desktop Entry]
Name=DualSense Manager
Comment=Manage PS5 DualSense controller triggers, RGB lightbar, audio and battery
Exec=$DIR/scripts/run.sh
Icon=dualsensectl-gui
Terminal=false
Type=Application
Categories=Utility;Settings;HardwareSettings;Game;
StartupNotify=true
EOF

chmod +x "$DESKTOP_DIR/dualsensectl-gui.desktop"
update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

echo "✓ Successfully installed DualSense Manager to $DESKTOP_DIR/dualsensectl-gui.desktop"
echo "You can now launch 'DualSense Manager' from your system application menu!"
