#!/usr/bin/env bash
# Script to install udev rules for Sony DualSense (PS5) and DualSense Edge controllers.
# This grants your user permission to configure the controller via /dev/hidraw without sudo.

set -e

RULES_FILE="/etc/udev/rules.d/70-dualsense.rules"

echo "Configuring DualSense udev permissions..."

sudo tee "$RULES_FILE" > /dev/null << 'EOF'
# PS5 DualSense controller over USB
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"

# PS5 DualSense controller over Bluetooth
KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"

# PS5 DualSense Edge controller over USB
KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", TAG+="uaccess"

# PS5 DualSense Edge controller over Bluetooth
KERNEL=="hidraw*", KERNELS=="*054C:0DF2*", MODE="0660", TAG+="uaccess"
EOF

sudo udevadm control --reload-rules
sudo udevadm trigger

echo "✓ DualSense udev rules successfully installed to $RULES_FILE"
echo "Please unplug and reconnect your controller (or restart Bluetooth)."
