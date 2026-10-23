"""
Lightbar and Player LEDs control widget.
Allows configuring RGB colors, brightness, player indicators, and dimming.
"""

from typing import Optional, Callable
from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtGui import QColor
from PyQt6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QGridLayout,
    QLabel,
    QPushButton,
    QSlider,
    QGroupBox,
    QColorDialog,
    QButtonGroup,
    QFrame,
    QCheckBox,
)

from ...core.wrapper import DualSenseCTLWrapper
from ..theme import PRESET_COLORS, COLOR_PS5_BLUE


class LightbarWidget(QGroupBox):
    color_changed = pyqtSignal(int, int, int, int)  # r, g, b, brightness

    def __init__(self, wrapper: DualSenseCTLWrapper, get_device_id_cb: Callable[[], Optional[str]], parent=None):
        super().__init__("LIGHTBAR & LEDS", parent)
        self.wrapper = wrapper
        self.get_device_id_cb = get_device_id_cb

        self.current_r = 0
        self.current_g = 112
        self.current_b = 209
        self.current_brightness = 255
        self.is_lightbar_enabled = True

        self._init_ui()

    def _init_ui(self):
        main_layout = QVBoxLayout(self)
        main_layout.setSpacing(14)

        # 1. Enable/Disable Toggle + Color Preview
        top_row = QHBoxLayout()
        self.chk_enable = QCheckBox("Enable Lightbar")
        self.chk_enable.setChecked(True)
        self.chk_enable.toggled.connect(self._on_toggle_lightbar)
        top_row.addWidget(self.chk_enable)

        top_row.addStretch()

        self.preview_frame = QFrame()
        self.preview_frame.setFixedSize(140, 30)
        self.preview_frame.setStyleSheet(
            f"background-color: rgb({self.current_r}, {self.current_g}, {self.current_b}); "
            f"border: 2px solid #ffffff; border-radius: 6px;"
        )
        self.lbl_color_hex = QLabel(f"#{self.current_r:02x}{self.current_g:02x}{self.current_b:02x}".upper())
        self.lbl_color_hex.setStyleSheet("font-weight: 700; font-family: monospace; color: #8b949e;")
        top_row.addWidget(self.lbl_color_hex)
        top_row.addWidget(self.preview_frame)
        main_layout.addLayout(top_row)

        # 2. Preset Colors Grid
        lbl_presets = QLabel("Quick Presets:")
        lbl_presets.setStyleSheet("font-weight: 600; color: #8b949e; font-size: 11px;")
        main_layout.addWidget(lbl_presets)

        presets_layout = QHBoxLayout()
        presets_layout.setSpacing(8)
        for name, hex_code in PRESET_COLORS:
            btn = QPushButton()
            btn.setFixedSize(28, 28)
            btn.setToolTip(name)
            btn.setStyleSheet(
                f"QPushButton {{ background-color: {hex_code}; border: 1px solid #30363d; border-radius: 14px; }}"
                f"QPushButton:hover {{ border: 2px solid #ffffff; }}"
            )
            btn.clicked.connect(lambda checked, c=hex_code: self._apply_hex_color(c))
            presets_layout.addWidget(btn)

        self.btn_custom = QPushButton("Custom Picker...")
        self.btn_custom.clicked.connect(self._open_color_picker)
        presets_layout.addWidget(self.btn_custom)
        presets_layout.addStretch()
        main_layout.addLayout(presets_layout)

        # 3. Brightness Slider
        brightness_box = QVBoxLayout()
        b_header = QHBoxLayout()
        lbl_b_title = QLabel("Lightbar Brightness:")
        lbl_b_title.setStyleSheet("color: #8b949e; font-size: 12px;")
        self.lbl_b_val = QLabel("255")
        self.lbl_b_val.setStyleSheet("font-weight: 600; color: #58a6ff;")
        b_header.addWidget(lbl_b_title)
        b_header.addStretch()
        b_header.addWidget(self.lbl_b_val)
        brightness_box.addLayout(b_header)

        self.slider_brightness = QSlider(Qt.Orientation.Horizontal)
        self.slider_brightness.setRange(0, 255)
        self.slider_brightness.setValue(255)
        self.slider_brightness.valueChanged.connect(self._on_brightness_changed)
        brightness_box.addWidget(self.slider_brightness)
        main_layout.addLayout(brightness_box)

        # Separator Line
        line = QFrame()
        line.setFrameShape(QFrame.Shape.HLine)
        line.setStyleSheet("border: 0.5px solid #21262d;")
        main_layout.addWidget(line)

        # 4. Player Indicator LEDs (1 to 5, and 0 for Off)
        player_box = QVBoxLayout()
        lbl_player = QLabel("Player Indicator LEDs (Below Touchpad):")
        lbl_player.setStyleSheet("font-weight: 600; color: #8b949e; font-size: 11px;")
        player_box.addWidget(lbl_player)

        player_btn_layout = QHBoxLayout()
        player_btn_layout.setSpacing(6)
        self.player_group = QButtonGroup(self)

        player_options = [
            ("Off", 0),
            ("P1 (●)", 1),
            ("P2 (●●)", 2),
            ("P3 (●●●)", 3),
            ("P4 (●●●●)", 4),
            ("P5 (●●●●●)", 5),
        ]
        for idx, (label, val) in enumerate(player_options):
            btn = QPushButton(label)
            btn.setCheckable(True)
            if val == 1:
                btn.setChecked(True)
            self.player_group.addButton(btn, val)
            player_btn_layout.addWidget(btn)

        self.player_group.idClicked.connect(self._on_player_led_clicked)
        player_box.addLayout(player_btn_layout)
        main_layout.addLayout(player_box)

        # 5. LED Dimming Level (High, Medium, Dim)
        dim_layout = QHBoxLayout()
        lbl_dim = QLabel("LED Dimming Level:")
        lbl_dim.setStyleSheet("color: #8b949e; font-size: 12px;")
        dim_layout.addWidget(lbl_dim)
        dim_layout.addStretch()

        self.dim_group = QButtonGroup(self)
        dim_opts = [("Bright (0)", 0), ("Medium (1)", 1), ("Dim (2)", 2)]
        for label, val in dim_opts:
            btn = QPushButton(label)
            btn.setCheckable(True)
            if val == 0:
                btn.setChecked(True)
            self.dim_group.addButton(btn, val)
            dim_layout.addWidget(btn)

        self.dim_group.idClicked.connect(self._on_dim_clicked)
        main_layout.addLayout(dim_layout)

    def _update_preview(self):
        color_str = f"rgb({self.current_r}, {self.current_g}, {self.current_b})"
        self.preview_frame.setStyleSheet(
            f"background-color: {color_str}; "
            f"border: 2px solid #58a6ff; border-radius: 6px;"
        )
        self.lbl_color_hex.setText(f"#{self.current_r:02x}{self.current_g:02x}{self.current_b:02x}".upper())

    def _apply_current_color(self):
        dev_id = self.get_device_id_cb()
        if not self.is_lightbar_enabled:
            self.wrapper.set_lightbar_state(False, device_id=dev_id)
            return

        self.wrapper.set_lightbar_color(
            self.current_r,
            self.current_g,
            self.current_b,
            brightness=self.current_brightness,
            device_id=dev_id
        )
        self._update_preview()
        self.color_changed.emit(self.current_r, self.current_g, self.current_b, self.current_brightness)

    def _apply_hex_color(self, hex_code: str):
        col = QColor(hex_code)
        self.current_r = col.red()
        self.current_g = col.green()
        self.current_b = col.blue()
        self._apply_current_color()

    def _open_color_picker(self):
        initial = QColor(self.current_r, self.current_g, self.current_b)
        col = QColorDialog.getColor(initial, self, "Select Lightbar Color")
        if col.isValid():
            self.current_r = col.red()
            self.current_g = col.green()
            self.current_b = col.blue()
            self._apply_current_color()

    def _on_toggle_lightbar(self, checked: bool):
        self.is_lightbar_enabled = checked
        dev_id = self.get_device_id_cb()
        self.wrapper.set_lightbar_state(checked, device_id=dev_id)
        if checked:
            self._apply_current_color()

    def _on_brightness_changed(self, val: int):
        self.current_brightness = val
        self.lbl_b_val.setText(str(val))
        self._apply_current_color()

    def _on_player_led_clicked(self, player_val: int):
        dev_id = self.get_device_id_cb()
        self.wrapper.set_player_leds(player_val, instant=True, device_id=dev_id)

    def _on_dim_clicked(self, dim_val: int):
        dev_id = self.get_device_id_cb()
        self.wrapper.set_led_brightness(dim_val, device_id=dev_id)
