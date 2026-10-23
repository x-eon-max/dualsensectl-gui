"""
Main Window for dualsensectl-gui application.
Coordinates tabs, background monitoring, system tray icon, and command logs.
"""

import os
import logging
from typing import List, Optional

from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QIcon, QAction
from PyQt6.QtWidgets import (
    QMainWindow,
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QTabWidget,
    QStatusBar,
    QSystemTrayIcon,
    QMenu,
    QMessageBox,
    QTextEdit,
    QLabel,
    QPushButton,
    QDialog,
    QDialogButtonBox,
)

from ..core.models import ControllerDevice, BatteryInfo, FirmwareInfo
from ..core.wrapper import DualSenseCTLWrapper
from ..core.monitor import DeviceMonitorWorker
from .theme import DARK_THEME_QSS
from .widgets.device_header import DeviceHeaderWidget
from .widgets.battery_widget import BatteryWidget
from .widgets.lightbar_widget import LightbarWidget
from .widgets.audio_mic_widget import AudioMicWidget
from .widgets.triggers_widget import TriggersWidget

logger = logging.getLogger(__name__)


class MainWindow(QMainWindow):
    def __init__(self, wrapper: DualSenseCTLWrapper, parent=None):
        super().__init__(parent)
        self.wrapper = wrapper
        self.monitor_worker = DeviceMonitorWorker(self.wrapper)

        self.setWindowTitle("DualSense Controller Manager (dualsensectl)")
        self.resize(760, 680)
        self.setMinimumSize(680, 580)
        self.setStyleSheet(DARK_THEME_QSS)

        # Set Window Icon
        icon_path = os.path.join(os.path.dirname(__file__), "..", "resources", "dualsense.svg")
        if os.path.exists(icon_path):
            self.setWindowIcon(QIcon(icon_path))

        self._init_ui()
        self._init_tray_icon()
        self._init_connections()

        # Start background polling
        self.monitor_worker.start()

    def _init_ui(self):
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(16, 14, 16, 14)
        main_layout.setSpacing(12)

        # 1. Device Header Bar
        self.header_widget = DeviceHeaderWidget(self.wrapper)
        main_layout.addWidget(self.header_widget)

        # 2. Tabs
        self.tabs = QTabWidget()

        # Tab 1: Dashboard (Battery, Lightbar, Quick Info)
        tab_dashboard = QWidget()
        dash_layout = QVBoxLayout(tab_dashboard)
        dash_layout.setContentsMargins(12, 12, 12, 12)
        dash_layout.setSpacing(12)

        # Split: Battery + Lightbar
        dash_grid = QHBoxLayout()
        dash_grid.setSpacing(12)

        left_col = QVBoxLayout()
        self.battery_widget = BatteryWidget()
        left_col.addWidget(self.battery_widget)

        # Hardware Info / Diagnostics Quick Card
        self.btn_firmware = QPushButton("ℹ View Controller Firmware / Info")
        self.btn_firmware.setFixedHeight(34)
        self.btn_firmware.clicked.connect(self._show_firmware_dialog)
        left_col.addWidget(self.btn_firmware)
        left_col.addStretch()

        dash_grid.addLayout(left_col, stretch=4)

        self.lightbar_widget = LightbarWidget(
            self.wrapper,
            get_device_id_cb=self.header_widget.get_selected_device_id
        )
        dash_grid.addWidget(self.lightbar_widget, stretch=6)
        dash_layout.addLayout(dash_grid)

        self.tabs.addTab(tab_dashboard, "🎮 Dashboard & Lightbar")

        # Tab 2: Adaptive Triggers Studio
        tab_triggers = QWidget()
        trig_layout = QVBoxLayout(tab_triggers)
        trig_layout.setContentsMargins(12, 12, 12, 12)
        self.triggers_widget = TriggersWidget(
            self.wrapper,
            get_device_id_cb=self.header_widget.get_selected_device_id
        )
        trig_layout.addWidget(self.triggers_widget)
        self.tabs.addTab(tab_triggers, "⚡ Adaptive Triggers (L2/R2)")

        # Tab 3: Audio & Microphone
        tab_audio = QWidget()
        aud_layout = QVBoxLayout(tab_audio)
        aud_layout.setContentsMargins(12, 12, 12, 12)
        self.audio_widget = AudioMicWidget(
            self.wrapper,
            get_device_id_cb=self.header_widget.get_selected_device_id
        )
        aud_layout.addWidget(self.audio_widget)
        self.tabs.addTab(tab_audio, "🎙 Audio & Microphone")

        # Tab 4: CLI Command Log & Raw Diagnostics
        tab_logs = QWidget()
        log_layout = QVBoxLayout(tab_logs)
        log_layout.setContentsMargins(12, 12, 12, 12)
        log_header = QHBoxLayout()
        log_title = QLabel("Executed dualsensectl Commands Log:")
        log_title.setStyleSheet("font-weight: 600; color: #8b949e;")
        log_header.addWidget(log_title)
        log_header.addStretch()
        btn_clear_log = QPushButton("Clear Log")
        btn_clear_log.clicked.connect(self._clear_command_log)
        log_header.addWidget(btn_clear_log)
        log_layout.addLayout(log_header)

        self.log_text = QTextEdit()
        self.log_text.setReadOnly(True)
        self.log_text.setStyleSheet(
            "background-color: #0d1117; color: #58a6ff; font-family: monospace; "
            "border: 1px solid #30363d; border-radius: 6px; padding: 8px;"
        )
        log_layout.addWidget(self.log_text)
        self.tabs.addTab(tab_logs, "📋 Command Log")

        main_layout.addWidget(self.tabs)

        # 3. Status Bar
        self.status_bar = QStatusBar()
        self.setStatusBar(self.status_bar)
        self.status_bar.showMessage("Ready. dualsensectl detected.")

        # Log periodic sync
        self.log_timer = QTimer(self)
        self.log_timer.timeout.connect(self._sync_command_log)
        self.log_timer.start(1000)

    def _init_tray_icon(self):
        if not QSystemTrayIcon.isSystemTrayAvailable():
            return

        self.tray_icon = QSystemTrayIcon(self)
        icon_path = os.path.join(os.path.dirname(__file__), "..", "resources", "dualsense.svg")
        if os.path.exists(icon_path):
            self.tray_icon.setIcon(QIcon(icon_path))
        self.tray_icon.setToolTip("DualSense Manager")

        # Tray Menu
        tray_menu = QMenu()
        act_show = QAction("Open Window", self)
        act_show.triggered.connect(self.showNormal)
        tray_menu.addAction(act_show)

        act_mute = QAction("Toggle Mic Mute", self)
        act_mute.triggered.connect(self.audio_widget._on_toggle_mic_mute)
        tray_menu.addAction(act_mute)

        tray_menu.addSeparator()
        act_quit = QAction("Quit", self)
        act_quit.triggered.connect(self.close)
        tray_menu.addAction(act_quit)

        self.tray_icon.setContextMenu(tray_menu)
        self.tray_icon.show()

    def _init_connections(self):
        # Header signals
        self.header_widget.refresh_requested.connect(self.monitor_worker.request_refresh)
        self.header_widget.device_selected.connect(self.monitor_worker.set_selected_device)
        self.header_widget.simulation_toggled.connect(self._on_simulation_toggled)

        # Monitor worker signals
        self.monitor_worker.devices_updated.connect(self._on_devices_updated)
        self.monitor_worker.battery_updated.connect(self._on_battery_updated)
        self.monitor_worker.device_connected.connect(self._on_device_connected)
        self.monitor_worker.device_disconnected.connect(self._on_device_disconnected)

    def _on_simulation_toggled(self, active: bool):
        msg = "Demo / Simulation Mode activated." if active else "Live Mode activated."
        self.status_bar.showMessage(msg, 3000)

    def _on_devices_updated(self, devices: List[ControllerDevice]):
        self.header_widget.update_devices(devices)

    def _on_battery_updated(self, battery: Optional[BatteryInfo]):
        self.battery_widget.update_battery(battery)
        if battery and hasattr(self, "tray_icon"):
            self.tray_icon.setToolTip(f"DualSense: {battery.percentage}% ({battery.status_text})")

    def _on_device_connected(self, dev: ControllerDevice):
        self.status_bar.showMessage(f"Device connected: {dev.display_name}", 4000)
        if hasattr(self, "tray_icon") and self.tray_icon.isVisible():
            self.tray_icon.showMessage(
                "DualSense Connected",
                f"Controller {dev.device_id} ({dev.connection_type.value}) is ready.",
                QSystemTrayIcon.MessageIcon.Information,
                3000
            )

    def _on_device_disconnected(self, dev_id: str):
        self.status_bar.showMessage(f"Device disconnected: {dev_id}", 4000)
        if hasattr(self, "tray_icon") and self.tray_icon.isVisible():
            self.tray_icon.showMessage(
                "DualSense Disconnected",
                f"Controller {dev_id} has been disconnected.",
                QSystemTrayIcon.MessageIcon.Warning,
                3000
            )

    def _sync_command_log(self):
        commands = self.wrapper._command_history
        if len(commands) != getattr(self, "_last_log_count", 0):
            self.log_text.setPlainText("\n".join(commands))
            self.log_text.verticalScrollBar().setValue(self.log_text.verticalScrollBar().maximum())
            self._last_log_count = len(commands)

    def _clear_command_log(self):
        self.wrapper._command_history.clear()
        self.log_text.clear()
        self._last_log_count = 0

    def _show_firmware_dialog(self):
        dev_id = self.header_widget.get_selected_device_id()
        info = self.wrapper.get_firmware_info(device_id=dev_id)

        dlg = QDialog(self)
        dlg.setWindowTitle("Controller Firmware & Hardware Diagnostics")
        dlg.resize(480, 360)
        dlg_layout = QVBoxLayout(dlg)

        text = QTextEdit()
        text.setReadOnly(True)
        text.setStyleSheet(
            "background-color: #0d1117; color: #58a6ff; font-family: monospace; "
            "border: 1px solid #30363d; border-radius: 6px; padding: 10px;"
        )

        if info:
            content = (
                f"=== DUALSENSE HARDWARE & FIRMWARE INFO ===\n\n"
                f"Hardware Revision: {info.hardware or 'Unknown'}\n"
                f"Build Date:        {info.build_date or 'Unknown'}\n"
                f"Firmware:          {info.firmware or 'Unknown'}\n"
                f"Firmware Version:  {info.fw_version or 'Unknown'}\n"
                f"Software Series:   {info.sw_series or 'Unknown'}\n"
                f"Update Version:    {info.update_version or 'Unknown'}\n\n"
                f"--- Raw CLI Output ---\n{info.raw_text}"
            )
        else:
            content = "No controller currently connected to read firmware info.\nTry enabling Demo Mode or connecting via USB/BT."

        text.setPlainText(content)
        dlg_layout.addWidget(text)

        btns = QDialogButtonBox(QDialogButtonBox.StandardButton.Close)
        btns.rejected.connect(dlg.reject)
        dlg_layout.addWidget(btns)

        dlg.exec()

    def closeEvent(self, event):
        """Clean up threads before exiting."""
        self.monitor_worker.stop()
        event.accept()
