"""
Unit tests for DualSenseCTL wrapper and data models.
"""

import unittest
from unittest.mock import MagicMock, patch

from dualsensectl_gui.core.models import (
    BatteryStatus,
    ConnectionType,
    TriggerMode,
    TriggerTarget,
)
from dualsensectl_gui.core.wrapper import DualSenseCTLWrapper


class TestDualSenseCTLWrapper(unittest.TestCase):
    def setUp(self):
        self.wrapper = DualSenseCTLWrapper(simulation_mode=True)

    def test_simulation_devices(self):
        devices = self.wrapper.list_devices()
        self.assertGreaterEqual(len(devices), 1)
        self.assertEqual(devices[0].device_id, "hidraw0")
        self.assertEqual(devices[0].connection_type, ConnectionType.BLUETOOTH)

    def test_simulation_battery(self):
        bat = self.wrapper.get_battery("hidraw0")
        self.assertIsNotNone(bat)
        self.assertEqual(bat.percentage, 84)
        self.assertEqual(bat.status, BatteryStatus.DISCHARGING)

    def test_parse_real_battery_string(self):
        real_wrapper = DualSenseCTLWrapper(simulation_mode=False)

        # Mocking execute_raw return
        with patch.object(real_wrapper, "execute_raw", return_value=(0, "85 discharging", "")):
            bat = real_wrapper.get_battery()
            self.assertIsNotNone(bat)
            self.assertEqual(bat.percentage, 85)
            self.assertEqual(bat.status, BatteryStatus.DISCHARGING)

        with patch.object(real_wrapper, "execute_raw", return_value=(0, "100 full", "")):
            bat = real_wrapper.get_battery()
            self.assertIsNotNone(bat)
            self.assertEqual(bat.percentage, 100)
            self.assertEqual(bat.status, BatteryStatus.FULL)

        with patch.object(real_wrapper, "execute_raw", return_value=(0, "42 charging", "")):
            bat = real_wrapper.get_battery()
            self.assertIsNotNone(bat)
            self.assertEqual(bat.percentage, 42)
            self.assertEqual(bat.status, BatteryStatus.CHARGING)

    def test_parse_device_list_output(self):
        real_wrapper = DualSenseCTLWrapper(simulation_mode=False)
        mock_output = "Devices:\n  hidraw0 (Bluetooth)\n  /dev/hidraw1 (USB)\n"
        with patch.object(real_wrapper, "execute_raw", return_value=(0, mock_output, "")):
            devices = real_wrapper.list_devices()
            self.assertEqual(len(devices), 2)
            self.assertEqual(devices[0].device_id, "hidraw0")
            self.assertEqual(devices[0].connection_type, ConnectionType.BLUETOOTH)
            self.assertEqual(devices[1].device_id, "hidraw1")
            self.assertEqual(devices[1].connection_type, ConnectionType.USB)

    def test_trigger_command_formatting(self):
        # Test weapon mode command generation
        self.wrapper._command_history.clear()
        success = self.wrapper.set_trigger_weapon(
            start=2,
            stop=6,
            strength=7,
            target=TriggerTarget.BOTH,
            device_id="hidraw0"
        )
        self.assertTrue(success)
        self.assertEqual(len(self.wrapper._command_history), 1)
        cmd = self.wrapper._command_history[0]
        self.assertIn("-d hidraw0", cmd)
        self.assertIn("trigger both weapon 2 6 7", cmd)

    def test_lightbar_command_formatting(self):
        self.wrapper._command_history.clear()
        success = self.wrapper.set_lightbar_color(0, 112, 209, brightness=200, device_id="hidraw0")
        self.assertTrue(success)
        self.assertEqual(len(self.wrapper._command_history), 1)
        cmd = self.wrapper._command_history[0]
        self.assertIn("lightbar 0 112 209 200", cmd)

    def test_firmware_info_parsing(self):
        mock_raw = (
            "Hardware: 0x03\n"
            "Build date: Oct 20 2024 14:22:00\n"
            "Firmware: 0x0284 (type 0)\n"
            "Fw version: 2 134 0\n"
            "Sw series: 3\n"
            "Update version: 0x0000\n"
        )
        real_wrapper = DualSenseCTLWrapper(simulation_mode=False)
        with patch.object(real_wrapper, "execute_raw", return_value=(0, mock_raw, "")):
            info = real_wrapper.get_firmware_info()
            self.assertIsNotNone(info)
            self.assertEqual(info.hardware, "0x03")
            self.assertEqual(info.build_date, "Oct 20 2024 14:22:00")
            self.assertEqual(info.fw_version, "2 134 0")


if __name__ == "__main__":
    unittest.main()
