"""
Battery gauge widget with real-time level and charging status display.
"""

from typing import Optional
from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QLabel,
    QProgressBar,
    QGroupBox,
)

from ...core.models import BatteryInfo, BatteryStatus


class BatteryWidget(QGroupBox):
    def __init__(self, parent=None):
        super().__init__("BATTERY STATUS", parent)
        self._init_ui()

    def _init_ui(self):
        layout = QVBoxLayout(self)
        layout.setSpacing(8)

        # Top row: Percentage & Status badge
        top_row = QHBoxLayout()
        self.label_pct = QLabel("-- %")
        self.label_pct.setStyleSheet("font-size: 26px; font-weight: 800; color: #f0f6fc;")
        top_row.addWidget(self.label_pct)

        top_row.addStretch()

        self.label_status = QLabel("DISCONNECTED")
        self.label_status.setStyleSheet(
            "background-color: #21262d; color: #8b949e; border-radius: 6px; "
            "padding: 4px 8px; font-weight: 600; font-size: 11px;"
        )
        top_row.addWidget(self.label_status)
        layout.addLayout(top_row)

        # Visual progress bar gauge
        self.progress_bar = QProgressBar()
        self.progress_bar.setRange(0, 100)
        self.progress_bar.setValue(0)
        self.progress_bar.setTextVisible(False)
        self.progress_bar.setFixedHeight(14)
        layout.addWidget(self.progress_bar)

        # Hint text
        self.label_hint = QLabel("Plug controller to monitor real-time charge")
        self.label_hint.setStyleSheet("font-size: 11px; color: #8b949e;")
        layout.addWidget(self.label_hint)

    def update_battery(self, battery: Optional[BatteryInfo]):
        if not battery:
            self.label_pct.setText("-- %")
            self.label_status.setText("DISCONNECTED")
            self.label_status.setStyleSheet(
                "background-color: #21262d; color: #8b949e; border-radius: 6px; "
                "padding: 4px 8px; font-weight: 600; font-size: 11px;"
            )
            self.progress_bar.setValue(0)
            self.progress_bar.setStyleSheet("QProgressBar::chunk { background-color: #30363d; }")
            self.label_hint.setText("No DualSense connected.")
            return

        pct = max(0, min(100, battery.percentage))
        self.progress_bar.setValue(pct)

        # Status text and charging icon
        is_charging = battery.status == BatteryStatus.CHARGING
        is_full = battery.status == BatteryStatus.FULL or pct >= 100

        if is_charging:
            status_text = f"⚡ CHARGING ({battery.status_text})"
            chunk_color = "#00f0ff"
            status_bg = "#003b46"
            status_fg = "#00f0ff"
            hint = "Controller is actively charging via USB"
        elif is_full:
            status_text = "FULL"
            chunk_color = "#238636"
            status_bg = "#123d26"
            status_fg = "#3fb950"
            hint = "Battery is fully charged"
        elif battery.status == BatteryStatus.NOT_CHARGING:
            status_text = "NOT CHARGING"
            chunk_color = "#d29922"
            status_bg = "#3d2e00"
            status_fg = "#e3b341"
            hint = "Connected, power supply threshold reached"
        else:
            status_text = "DISCHARGING"
            if pct > 50:
                chunk_color = "#238636"
                status_bg = "#123d26"
                status_fg = "#3fb950"
                hint = "Battery level is healthy"
            elif pct > 20:
                chunk_color = "#d29922"
                status_bg = "#3d2e00"
                status_fg = "#e3b341"
                hint = "Battery level is moderate"
            else:
                chunk_color = "#da3633"
                status_bg = "#4c131a"
                status_fg = "#f85149"
                hint = "Battery low! Connect USB cable"

        self.label_pct.setText(f"{pct}%")
        self.label_status.setText(status_text)
        self.label_status.setStyleSheet(
            f"background-color: {status_bg}; color: {status_fg}; border-radius: 6px; "
            f"padding: 4px 8px; font-weight: 700; font-size: 11px;"
        )
        self.progress_bar.setStyleSheet(f"QProgressBar::chunk {{ background-color: {chunk_color}; border-radius: 5px; }}")
        self.label_hint.setText(hint)
