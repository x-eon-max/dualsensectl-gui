#!/usr/bin/env bash
# Launcher for dualsensectl-gui

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PYTHONPATH="$DIR:$PYTHONPATH"

# Enable Wayland by default if running Wayland session, or fallback to XCB
if [ -n "$WAYLAND_DISPLAY" ]; then
    export QT_QPA_PLATFORM="wayland;xcb"
fi

python3 -m dualsensectl_gui "$@"
