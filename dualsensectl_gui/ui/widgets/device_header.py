"""
Header widget for DualSense device selection, connection status, and quick actions.
"""

from typing import List, Optional
from PyQt6.QtCore import pyqtSignal, Qt
from PyQt6.QtWidgets import (
    QWidget,
    QHBoxLayout,
    QVBoxLayout,
    QLabel,
    QComboBox,
    QPushButton,
    QFrame,
    QMessageBox,
)

from ...core.models import ControllerDevice, ConnectionType
from ...core.wrapper import DualSenseCTLWrapper


class DeviceHeaderWidget(QWidget):
    device_selected = pyqtSignal(str)          # Emits device_id
    refresh_requested = pyqtSignal()
    simulation_toggled = pyqtSignal(bool)

    def __init__(self, wrapper: DualSenseCTLWrapper, parent=None):
        super().__init__(parent)
        self.wrapper = wrapper
        self.devices: List[ControllerDevice] = []
        self._init_ui()

    def _init_ui(self):
        layout = QHBoxLayout(self)
        layout.setContentsMargins(12, 10, 12, 10)
        layout.setSpacing(12)

        # Title / Brand
        brand_layout = QVBoxLayout()
        brand_layout.setSpacing(2)
        title = QLabel("DUALSENSE DOCK")
        title.setStyleSheet("font-weight: 800; font-size: 15px; color: #58a6ff; letter-spacing: 1px;")
        subtitle = QLabel("Linux Controller Manager (dualsensectl)")
        subtitle.setStyleSheet("font-size: 11px; color: #8b949e;")
        brand_layout.addWidget(title)
        brand_layout.addWidget(subtitle)
        layout.addLayout(brand_layout)

        layout.addStretch()

        # Connection Status Badge
        self.status_badge = QLabel("DISCONNECTED")
        self.status_badge.setStyleSheet(
            "background-color: #21262d; color: #8b949e; border: 1px solid #30363d; "
            "border-radius: 12px; padding: 4px 12px; font-weight: 700; font-size: 11px;"
        )
        layout.addWidget(self.status_badge)

        # Device Selector Combo
        self.device_combo = QComboBox()
        self.device_combo.setMinimumWidth(200)
        self.device_combo.currentIndexChanged.connect(self._on_combo_changed)
        layout.addWidget(self.device_combo)

        # Refresh Button
        self.btn_refresh = QPushButton("⟳ Refresh")
        self.btn_refresh.setToolTip("Scan for connected DualSense controllers")
        self.btn_refresh.clicked.connect(self.refresh_requested.emit)
        layout.addWidget(self.btn_refresh)

        # Power Off Button (BT only)
        self.btn_power_off = QPushButton("⏻ Power Off")
        self.btn_power_off.setObjectName("dangerButton")
        self.btn_power_off.setToolTip("Turn off controller via Bluetooth")
        self.btn_power_off.setEnabled(False)
        self.btn_power_off.clicked.connect(self._on_power_off)
        layout.addWidget(self.btn_power_off)

        # Simulation Mode Toggle
        self.btn_sim = QPushButton("⚡ Demo Mode")
        self.btn_sim.setCheckable(True)
        self.btn_sim.setChecked(self.wrapper.simulation_mode)
        self.btn_sim.setToolTip("Toggle simulated controller for testing without physical device")
        self.btn_sim.toggled.connect(self._on_simulation_toggled)
        self._update_sim_btn_style(self.wrapper.simulation_mode)
        layout.addWidget(self.btn_sim)

    def _update_sim_btn_style(self, active: bool):
        if active:
            self.btn_sim.setStyleSheet(
                "background-color: #e040fb; color: #ffffff; border: 1px solid #ea80fc; font-weight: 600;"
            )
            self.btn_sim.setText("⚡ Demo Mode: ON")
        else:
            self.btn_sim.setStyleSheet("")
            self.btn_sim.setText("⚡ Demo Mode: OFF")

    def _on_simulation_toggled(self, checked: bool):
        self.wrapper.simulation_mode = checked
        self._update_sim_btn_style(checked)
        self.simulation_toggled.emit(checked)
        self.refresh_requested.emit()

    def update_devices(self, devices: List[ControllerDevice]):
        self.devices = devices
        current_data = self.device_combo.currentData()

        self.device_combo.blockSignals(True)
        self.device_combo.clear()

        if not devices:
            self.device_combo.addItem("No DualSense detected", "")
            self.device_combo.setEnabled(False)
            self.btn_power_off.setEnabled(False)
            self.status_badge.setText("DISCONNECTED")
            self.status_badge.setStyleSheet(
                "background-color: #21262d; color: #8b949e; border: 1px solid #30363d; "
                "border-radius: 12px; padding: 4px 12px; font-weight: 700; font-size: 11px;"
            )
        else:
            self.device_combo.setEnabled(True)
            selected_idx = 0
            for idx, dev in enumerate(devices):
                label = f"{dev.device_id} ({dev.connection_type.value})"
                self.device_combo.addItem(label, dev.device_id)
                if dev.device_id == current_data:
                    selected_idx = idx

            self.device_combo.setCurrentIndex(selected_idx)
            active_dev = devices[selected_idx]
            self._update_status_for_device(active_dev)

        self.device_combo.blockSignals(False)

    def _update_status_for_device(self, dev: ControllerDevice):
        is_bt = dev.connection_type == ConnectionType.BLUETOOTH
        self.btn_power_off.setEnabled(is_bt)

        if is_bt:
            self.status_badge.setText("CONNECTED (BLUETOOTH)")
            self.status_badge.setStyleSheet(
                "background-color: #0c2d6b; color: #58a6ff; border: 1px solid #1f6feb; "
                "border-radius: 12px; padding: 4px 12px; font-weight: 700; font-size: 11px;"
            )
        else:
            self.status_badge.setText("CONNECTED (USB)")
            self.status_badge.setStyleSheet(
                "background-color: #123d26; color: #3fb950; border: 1px solid #238636; "
                "border-radius: 12px; padding: 4px 12px; font-weight: 700; font-size: 11px;"
            )

    def _on_combo_changed(self, index: int):
        dev_id = self.device_combo.currentData()
        if dev_id:
            for dev in self.devices:
                if dev.device_id == dev_id:
                    self._update_status_for_device(dev)
                    break
            self.device_selected.emit(dev_id)

    def _on_power_off(self):
        dev_id = self.device_combo.currentData()
        reply = QMessageBox.question(
            self,
            "Power Off Controller",
            f"Are you sure you want to turn off DualSense ({dev_id})?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        )
        if reply == QMessageBox.StandardButton.Yes:
            success = self.wrapper.power_off(device_id=dev_id)
            if not success:
                QMessageBox.warning(self, "Power Off Failed", "Could not turn off the controller.")
            else:
                self.refresh_requested.emit()

    def get_selected_device_id(self) -> Optional[str]:
        data = self.device_combo.currentData()
        return data if data else None
