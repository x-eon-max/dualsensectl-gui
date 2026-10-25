#!/usr/bin/env bash
# Launcher for DualSense Expressive (Material 3 Expressive)

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Check if binary is built, otherwise build it
if [ ! -f "$DIR/build/dualsense-expressive" ]; then
    echo "⚡ Binary not found, building DualSense Expressive..."
    "$DIR/scripts/build.sh"
fi

# Enable Wayland by default if running Wayland session, or fallback to XCB
if [ -n "$WAYLAND_DISPLAY" ]; then
    export QT_QPA_PLATFORM="wayland;xcb"
fi

exec "$DIR/build/dualsense-expressive" "$@"
