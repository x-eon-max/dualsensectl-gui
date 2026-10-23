"""
Headless GUI integration tests using offscreen Qt platform.
"""

import os
import sys
import unittest

os.environ["QT_QPA_PLATFORM"] = "offscreen"

from PyQt6.QtWidgets import QApplication
from dualsensectl_gui.core.wrapper import DualSenseCTLWrapper
from dualsensectl_gui.ui.main_window import MainWindow
from dualsensectl_gui.core.models import BatteryInfo, BatteryStatus, ControllerDevice, ConnectionType


class TestGUIComponents(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = QApplication.instance() or QApplication(sys.argv)

    def setUp(self):
        self.wrapper = DualSenseCTLWrapper(simulation_mode=True)
        self.window = MainWindow(self.wrapper)

    def tearDown(self):
        self.window.monitor_worker.stop()
        self.window.close()

    def test_window_initialization(self):
        self.assertIsNotNone(self.window)
        self.assertEqual(self.window.tabs.count(), 4)

    def test_header_device_update(self):
        devices = [
            ControllerDevice(device_id="hidraw0", connection_type=ConnectionType.BLUETOOTH),
            ControllerDevice(device_id="hidraw1", connection_type=ConnectionType.USB),
        ]
        self.window.header_widget.update_devices(devices)
        self.assertEqual(self.window.header_widget.device_combo.count(), 2)
        self.assertEqual(self.window.header_widget.get_selected_device_id(), "hidraw0")

    def test_battery_widget_update(self):
        bat = BatteryInfo(percentage=75, status=BatteryStatus.CHARGING, status_text="charging")
        self.window.battery_widget.update_battery(bat)
        self.assertEqual(self.window.battery_widget.label_pct.text(), "75%")
        self.assertIn("CHARGING", self.window.battery_widget.label_status.text())

    def test_lightbar_color_action(self):
        self.window.lightbar_widget._apply_hex_color("#00F0FF")
        self.assertEqual(self.window.lightbar_widget.current_r, 0)
        self.assertEqual(self.window.lightbar_widget.current_g, 240)
        self.assertEqual(self.window.lightbar_widget.current_b, 255)
        self.assertIn("lightbar 0 240 255", self.wrapper._command_history[-1])

    def test_trigger_apply_action(self):
        self.window.triggers_widget.combo_presets.setCurrentIndex(1)  # handgun preset
        self.window.triggers_widget.apply_current_trigger_config()
        last_cmd = self.wrapper._command_history[-1]
        self.assertIn("trigger both weapon", last_cmd)

    def test_audio_mute_toggle(self):
        self.window.audio_widget._on_toggle_mic_mute()
        self.assertTrue(self.window.audio_widget.is_mic_muted)
        self.assertIn("microphone off", self.wrapper._command_history[-2])
        self.assertIn("microphone-led on", self.wrapper._command_history[-1])


if __name__ == "__main__":
    unittest.main()
