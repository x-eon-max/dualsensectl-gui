"""
Audio, Microphone, and Haptic attenuation control widget.
Controls microphone mute state, mic LED, speaker routing, volume, and rumble attenuation.
"""

from typing import Optional, Callable
from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtWidgets import (
    QWidget,
    QVBoxLayout,
    QHBoxLayout,
    QGridLayout,
    QLabel,
    QPushButton,
    QSlider,
    QGroupBox,
    QComboBox,
    QFrame,
)

from ...core.models import MicLedState, MicMode, SpeakerMode
from ...core.wrapper import DualSenseCTLWrapper


class AudioMicWidget(QGroupBox):
    def __init__(self, wrapper: DualSenseCTLWrapper, get_device_id_cb: Callable[[], Optional[str]], parent=None):
        super().__init__("AUDIO & MICROPHONE", parent)
        self.wrapper = wrapper
        self.get_device_id_cb = get_device_id_cb
        self.is_mic_muted = False
        self._init_ui()

    def _init_ui(self):
        main_layout = QVBoxLayout(self)
        main_layout.setSpacing(14)

        # 1. Big Mute / Unmute Toggle Button with Status
        mic_row = QHBoxLayout()
        self.btn_mic_mute = QPushButton("🎙 MICROPHONE ACTIVE")
        self.btn_mic_mute.setFixedHeight(44)
        self.btn_mic_mute.setCheckable(True)
        self.btn_mic_mute.setChecked(False)
        self.btn_mic_mute.setStyleSheet(
            "background-color: #123d26; color: #3fb950; border: 1px solid #238636; "
            "font-weight: 700; font-size: 13px; border-radius: 8px;"
        )
        self.btn_mic_mute.clicked.connect(self._on_toggle_mic_mute)
        mic_row.addWidget(self.btn_mic_mute)
        main_layout.addLayout(mic_row)

        # 2. Mic LED & Mode Options
        options_grid = QGridLayout()
        options_grid.setSpacing(8)

        # Mic LED state
        lbl_mic_led = QLabel("Mic LED State:")
        lbl_mic_led.setStyleSheet("color: #8b949e; font-size: 11px;")
        self.combo_mic_led = QComboBox()
        self.combo_mic_led.addItem("LED Solid (on)", MicLedState.ON)
        self.combo_mic_led.addItem("LED Off (off)", MicLedState.OFF)
        self.combo_mic_led.addItem("LED Pulsing (pulse)", MicLedState.PULSE)
        self.combo_mic_led.currentIndexChanged.connect(self._on_mic_led_changed)
        options_grid.addWidget(lbl_mic_led, 0, 0)
        options_grid.addWidget(self.combo_mic_led, 0, 1)

        # Mic Mode
        lbl_mic_mode = QLabel("Mic Routing Mode:")
        lbl_mic_mode.setStyleSheet("color: #8b949e; font-size: 11px;")
        self.combo_mic_mode = QComboBox()
        self.combo_mic_mode.addItem("Chat Audio (chat)", MicMode.CHAT)
        self.combo_mic_mode.addItem("Speech Recognition (asr)", MicMode.ASR)
        self.combo_mic_mode.addItem("Both (both)", MicMode.BOTH)
        self.combo_mic_mode.currentIndexChanged.connect(self._on_mic_mode_changed)
        options_grid.addWidget(lbl_mic_mode, 1, 0)
        options_grid.addWidget(self.combo_mic_mode, 1, 1)

        # Speaker Routing
        lbl_speaker = QLabel("Speaker Routing:")
        lbl_speaker.setStyleSheet("color: #8b949e; font-size: 11px;")
        self.combo_speaker = QComboBox()
        self.combo_speaker.addItem("Internal Controller (internal)", SpeakerMode.INTERNAL)
        self.combo_speaker.addItem("3.5mm Headphone (headphone)", SpeakerMode.HEADPHONE)
        self.combo_speaker.addItem("Both (both)", SpeakerMode.BOTH)
        self.combo_speaker.currentIndexChanged.connect(self._on_speaker_changed)
        options_grid.addWidget(lbl_speaker, 2, 0)
        options_grid.addWidget(self.combo_speaker, 2, 1)

        main_layout.addLayout(options_grid)

        # Separator
        line = QFrame()
        line.setFrameShape(QFrame.Shape.HLine)
        line.setStyleSheet("border: 0.5px solid #21262d;")
        main_layout.addWidget(line)

        # 3. Audio Volume Slider
        vol_box = QVBoxLayout()
        vol_header = QHBoxLayout()
        lbl_vol_title = QLabel("Speaker / Headphone Volume:")
        lbl_vol_title.setStyleSheet("color: #8b949e; font-size: 12px;")
        self.lbl_vol_val = QLabel("180 / 255")
        self.lbl_vol_val.setStyleSheet("font-weight: 600; color: #58a6ff;")
        vol_header.addWidget(lbl_vol_title)
        vol_header.addStretch()
        vol_header.addWidget(self.lbl_vol_val)
        vol_box.addLayout(vol_header)

        self.slider_vol = QSlider(Qt.Orientation.Horizontal)
        self.slider_vol.setRange(0, 255)
        self.slider_vol.setValue(180)
        self.slider_vol.valueChanged.connect(self._on_volume_changed)
        vol_box.addWidget(self.slider_vol)
        main_layout.addLayout(vol_box)

        # 4. Attenuation Sliders (Rumble & Trigger Vibration)
        att_box = QVBoxLayout()
        att_header = QHBoxLayout()
        lbl_att_title = QLabel("Haptic Motor Attenuation (0 = Full Power, 7 = Weakest):")
        lbl_att_title.setStyleSheet("color: #8b949e; font-size: 11px;")
        self.lbl_att_val = QLabel("Rumble: 0 | Trigger: 0")
        self.lbl_att_val.setStyleSheet("font-weight: 600; color: #58a6ff; font-size: 11px;")
        att_header.addWidget(lbl_att_title)
        att_header.addStretch()
        att_header.addWidget(self.lbl_att_val)
        att_box.addLayout(att_header)

        att_sliders = QHBoxLayout()
        self.slider_rumble = QSlider(Qt.Orientation.Horizontal)
        self.slider_rumble.setRange(0, 7)
        self.slider_rumble.setValue(0)
        self.slider_rumble.valueChanged.connect(self._on_attenuation_changed)

        self.slider_trigger_att = QSlider(Qt.Orientation.Horizontal)
        self.slider_trigger_att.setRange(0, 7)
        self.slider_trigger_att.setValue(0)
        self.slider_trigger_att.valueChanged.connect(self._on_attenuation_changed)

        att_sliders.addWidget(QLabel("Rumble:"))
        att_sliders.addWidget(self.slider_rumble)
        att_sliders.addWidget(QLabel("Trigger:"))
        att_sliders.addWidget(self.slider_trigger_att)
        att_box.addLayout(att_sliders)

        main_layout.addLayout(att_box)

    def _on_toggle_mic_mute(self):
        dev_id = self.get_device_id_cb()
        self.is_mic_muted = not self.is_mic_muted

        if self.is_mic_muted:
            # Muted: disable microphone, turn mic LED on (solid orange)
            self.wrapper.set_microphone(False, device_id=dev_id)
            self.wrapper.set_microphone_led(MicLedState.ON, device_id=dev_id)
            self.btn_mic_mute.setText("🔇 MUTED (Mic LED: Solid Orange)")
            self.btn_mic_mute.setStyleSheet(
                "background-color: #5c1e00; color: #ffab70; border: 1px solid #ff6b00; "
                "font-weight: 700; font-size: 13px; border-radius: 8px;"
            )
        else:
            # Unmuted: enable microphone, turn mic LED off
            self.wrapper.set_microphone(True, device_id=dev_id)
            self.wrapper.set_microphone_led(MicLedState.OFF, device_id=dev_id)
            self.btn_mic_mute.setText("🎙 MICROPHONE ACTIVE")
            self.btn_mic_mute.setStyleSheet(
                "background-color: #123d26; color: #3fb950; border: 1px solid #238636; "
                "font-weight: 700; font-size: 13px; border-radius: 8px;"
            )

    def _on_mic_led_changed(self):
        dev_id = self.get_device_id_cb()
        state = self.combo_mic_led.currentData()
        if state:
            self.wrapper.set_microphone_led(state, device_id=dev_id)

    def _on_mic_mode_changed(self):
        dev_id = self.get_device_id_cb()
        mode = self.combo_mic_mode.currentData()
        if mode:
            self.wrapper.set_microphone_mode(mode, device_id=dev_id)

    def _on_speaker_changed(self):
        dev_id = self.get_device_id_cb()
        spk = self.combo_speaker.currentData()
        if spk:
            self.wrapper.set_speaker(spk, device_id=dev_id)

    def _on_volume_changed(self, val: int):
        dev_id = self.get_device_id_cb()
        self.lbl_vol_val.setText(f"{val} / 255")
        self.wrapper.set_volume(val, device_id=dev_id)

    def _on_attenuation_changed(self):
        dev_id = self.get_device_id_cb()
        rumble = self.slider_rumble.value()
        trigger = self.slider_trigger_att.value()
        self.lbl_att_val.setText(f"Rumble: {rumble} | Trigger: {trigger}")
        self.wrapper.set_attenuation(rumble, trigger, device_id=dev_id)
