"""
Background monitor thread for DualSense controller discovery and status polling.
Uses PyQt6 QThread and signals to keep the UI completely non-blocking.
"""

import logging
import time
from typing import List, Optional

from PyQt6.QtCore import QThread, pyqtSignal

from .models import BatteryInfo, ControllerDevice
from .wrapper import DualSenseCTLWrapper

logger = logging.getLogger(__name__)


class DeviceMonitorWorker(QThread):
    """
    Background worker thread that monitors controller status
    and emits Qt signals when changes are detected.
    """
    devices_updated = pyqtSignal(list)               # Emits List[ControllerDevice]
    battery_updated = pyqtSignal(object)             # Emits BatteryInfo or None
    device_connected = pyqtSignal(ControllerDevice)  # Emits newly connected device
    device_disconnected = pyqtSignal(str)            # Emits device_id
    error_occurred = pyqtSignal(str)                 # Emits error description

    def __init__(self, wrapper: DualSenseCTLWrapper, poll_interval_sec: float = 3.0, parent=None):
        super().__init__(parent)
        self.wrapper = wrapper
        self.poll_interval_sec = poll_interval_sec
        self._is_running = True
        self._force_refresh_flag = False
        self._current_selected_device_id: Optional[str] = None
        self._known_devices: List[str] = []

    def set_selected_device(self, device_id: Optional[str]):
        """Change which device's battery is actively monitored."""
        self._current_selected_device_id = device_id
        self._force_refresh_flag = True

    def request_refresh(self):
        """Trigger an immediate poll without waiting for interval."""
        self._force_refresh_flag = True

    def stop(self):
        """Gracefully stop the worker thread."""
        self._is_running = False
        self.wait(2000)

    def run(self):
        logger.info("Device monitor thread started.")
        while self._is_running:
            try:
                # 1. Discover devices
                devices = self.wrapper.list_devices()
                current_ids = [d.device_id for d in devices]

                # Check for additions and removals
                for dev in devices:
                    if dev.device_id not in self._known_devices:
                        self.device_connected.emit(dev)

                for known_id in self._known_devices:
                    if known_id not in current_ids:
                        self.device_disconnected.emit(known_id)

                self._known_devices = current_ids
                self.devices_updated.emit(devices)

                # 2. Poll battery for selected device
                active_id = self._current_selected_device_id
                if not active_id and devices:
                    active_id = devices[0].device_id

                if active_id:
                    bat = self.wrapper.get_battery(device_id=active_id)
                    self.battery_updated.emit(bat)
                else:
                    self.battery_updated.emit(None)

            except Exception as e:
                logger.error(f"Error during monitor loop: {e}", exc_info=True)
                self.error_occurred.emit(str(e))

            # Sleep in small increments to allow responsive stopping / force refresh
            steps = int(self.poll_interval_sec * 10)
            for _ in range(max(1, steps)):
                if not self._is_running:
                    break
                if self._force_refresh_flag:
                    self._force_refresh_flag = False
                    break
                time.sleep(0.1)

        logger.info("Device monitor thread stopped.")
