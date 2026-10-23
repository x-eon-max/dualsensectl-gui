"""
Adaptive Triggers (L2 / R2) configuration and testing studio.
Supports all 7 dualsensectl trigger modes, gaming presets, and interactive visualizer.
"""

from typing import Optional, Callable, Dict, Any
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
    QRadioButton,
    QButtonGroup,
    QStackedWidget,
    QFrame,
    QProgressBar,
)

from ...core.models import TriggerMode, TriggerTarget
from ...core.wrapper import DualSenseCTLWrapper


class TriggersWidget(QGroupBox):
    def __init__(self, wrapper: DualSenseCTLWrapper, get_device_id_cb: Callable[[], Optional[str]], parent=None):
        super().__init__("ADAPTIVE TRIGGERS STUDIO (L2 / R2)", parent)
        self.wrapper = wrapper
        self.get_device_id_cb = get_device_id_cb
        self._init_ui()

    def _init_ui(self):
        main_layout = QVBoxLayout(self)
        main_layout.setSpacing(14)

        # 1. Target Selector (Left L2, Right R2, Both)
        target_layout = QHBoxLayout()
        lbl_target = QLabel("Target Trigger:")
        lbl_target.setStyleSheet("font-weight: 600; color: #8b949e;")
        target_layout.addWidget(lbl_target)

        self.target_group = QButtonGroup(self)
        targets = [("Left (L2)", TriggerTarget.LEFT), ("Right (R2)", TriggerTarget.RIGHT), ("Both (L2 + R2)", TriggerTarget.BOTH)]
        for idx, (label, val) in enumerate(targets):
            btn = QPushButton(label)
            btn.setCheckable(True)
            if val == TriggerTarget.BOTH:
                btn.setChecked(True)
            self.target_group.addButton(btn, idx)
            btn.setProperty("target_val", val)
            target_layout.addWidget(btn)

        target_layout.addStretch()
        main_layout.addLayout(target_layout)

        # 2. Preset Selection Dropdown
        preset_layout = QHBoxLayout()
        lbl_preset = QLabel("Game / Effect Preset:")
        lbl_preset.setStyleSheet("font-weight: 600; color: #8b949e;")
        preset_layout.addWidget(lbl_preset)

        self.combo_presets = QComboBox()
        self.combo_presets.addItem("Custom Configuration", "custom")
        self.combo_presets.addItem("Semi-Auto Handgun (Weapon)", "handgun")
        self.combo_presets.addItem("Heavy Shotgun Wall (Weapon)", "shotgun")
        self.combo_presets.addItem("Sniper Heavy Resistance (Feedback)", "sniper")
        self.combo_presets.addItem("Compound Bow & Tension (Bow)", "bow")
        self.combo_presets.addItem("Rapid Recoil Machine Gun (Machine)", "machine_gun")
        self.combo_presets.addItem("Horse Gallop Rhythm (Galloping)", "gallop")
        self.combo_presets.addItem("Engine Hum / Buzz (Vibration)", "engine")
        self.combo_presets.addItem("Disabled / Smooth (Off)", "off")
        self.combo_presets.currentIndexChanged.connect(self._on_preset_selected)
        preset_layout.addWidget(self.combo_presets)
        main_layout.addLayout(preset_layout)

        # 3. Trigger Mode Selector
        mode_layout = QHBoxLayout()
        lbl_mode = QLabel("Operational Mode:")
        lbl_mode.setStyleSheet("font-weight: 600; color: #8b949e;")
        mode_layout.addWidget(lbl_mode)

        self.combo_mode = QComboBox()
        self.combo_mode.addItem("Off (Standard)", TriggerMode.OFF)
        self.combo_mode.addItem("Feedback (Resistance)", TriggerMode.FEEDBACK)
        self.combo_mode.addItem("Weapon (Gun trigger)", TriggerMode.WEAPON)
        self.combo_mode.addItem("Bow (Elastic snap)", TriggerMode.BOW)
        self.combo_mode.addItem("Machine (Alternating vibration)", TriggerMode.MACHINE)
        self.combo_mode.addItem("Galloping (Rhythmic steps)", TriggerMode.GALLOPING)
        self.combo_mode.addItem("Vibration (Motor arm)", TriggerMode.VIBRATION)
        self.combo_mode.currentIndexChanged.connect(self._on_mode_changed)
        mode_layout.addWidget(self.combo_mode)
        main_layout.addLayout(mode_layout)

        # 4. Dynamic Parameter Stack
        self.param_stack = QStackedWidget()
        self._build_param_pages()
        main_layout.addWidget(self.param_stack)

        # 5. Visualizer Bar
        viz_box = QVBoxLayout()
        viz_header = QHBoxLayout()
        lbl_viz = QLabel("Trigger Travel Simulation (0% Pressed -> 100% Fully Pulled):")
        lbl_viz.setStyleSheet("font-size: 11px; color: #8b949e;")
        viz_header.addWidget(lbl_viz)
        viz_box.addLayout(viz_header)

        self.viz_progress = QProgressBar()
        self.viz_progress.setRange(0, 100)
        self.viz_progress.setValue(100)
        self.viz_progress.setFixedHeight(12)
        self.viz_progress.setTextVisible(False)
        self.viz_progress.setStyleSheet("QProgressBar::chunk { background-color: #58a6ff; border-radius: 4px; }")
        viz_box.addWidget(self.viz_progress)

        self.lbl_viz_desc = QLabel("Mode: Off - Standard smooth resistance across travel.")
        self.lbl_viz_desc.setStyleSheet("font-size: 11px; color: #58a6ff; font-style: italic;")
        viz_box.addWidget(self.lbl_viz_desc)
        main_layout.addLayout(viz_box)

        # 6. Apply & Reset Action Buttons
        btn_layout = QHBoxLayout()
        self.btn_apply = QPushButton("⚡ Apply Effect to Trigger")
        self.btn_apply.setObjectName("primaryButton")
        self.btn_apply.setFixedHeight(36)
        self.btn_apply.clicked.connect(self.apply_current_trigger_config)
        btn_layout.addWidget(self.btn_apply)

        self.btn_reset = QPushButton("Reset to Default (Off)")
        self.btn_reset.setFixedHeight(36)
        self.btn_reset.clicked.connect(self.reset_triggers)
        btn_layout.addWidget(self.btn_reset)

        main_layout.addLayout(btn_layout)

    def _build_param_pages(self):
        # Page 0: Off
        p_off = QWidget()
        layout_off = QVBoxLayout(p_off)
        lbl_off = QLabel("Trigger motor disengaged. Normal spring behavior.")
        lbl_off.setStyleSheet("color: #8b949e; font-style: italic;")
        layout_off.addWidget(lbl_off)
        self.param_stack.addWidget(p_off)

        # Page 1: Feedback (pos 0-9, str 1-8)
        p_fb = QWidget()
        l_fb = QGridLayout(p_fb)
        self.slider_fb_pos = self._create_labeled_slider("Resistance Start Position (0-9):", 0, 9, 2, l_fb, 0)
        self.slider_fb_str = self._create_labeled_slider("Resistance Strength (1-8):", 1, 8, 6, l_fb, 1)
        self.param_stack.addWidget(p_fb)

        # Page 2: Weapon (start 2-7, stop start+1..8, str 1-8)
        p_wp = QWidget()
        l_wp = QGridLayout(p_wp)
        self.slider_wp_start = self._create_labeled_slider("Break Start (2-7):", 2, 7, 2, l_wp, 0)
        self.slider_wp_stop = self._create_labeled_slider("Break Stop (3-8):", 3, 8, 5, l_wp, 1)
        self.slider_wp_str = self._create_labeled_slider("Actuation Strength (1-8):", 1, 8, 7, l_wp, 2)
        self.param_stack.addWidget(p_wp)

        # Page 3: Bow (start 0-8, stop start+1..8, str 1-8, snap 1-8)
        p_bow = QWidget()
        l_bow = QGridLayout(p_bow)
        self.slider_bow_start = self._create_labeled_slider("Pull Start (0-8):", 0, 8, 1, l_bow, 0)
        self.slider_bow_stop = self._create_labeled_slider("Full Draw Stop (1-8):", 1, 8, 7, l_bow, 1)
        self.slider_bow_str = self._create_labeled_slider("String Tension (1-8):", 1, 8, 6, l_bow, 2)
        self.slider_bow_snap = self._create_labeled_slider("Snap Force Release (1-8):", 1, 8, 8, l_bow, 3)
        self.param_stack.addWidget(p_bow)

        # Page 4: Machine (start 1-8, stop start+1..8, str_a 0-7, str_b 0-7, freq 1-20, period 1-10)
        p_mach = QWidget()
        l_mach = QGridLayout(p_mach)
        self.slider_mach_start = self._create_labeled_slider("Kick Start (1-8):", 1, 8, 1, l_mach, 0)
        self.slider_mach_stop = self._create_labeled_slider("Kick Stop (2-8):", 2, 8, 7, l_mach, 1)
        self.slider_mach_a = self._create_labeled_slider("Strength A (0-7):", 0, 7, 2, l_mach, 2)
        self.slider_mach_b = self._create_labeled_slider("Strength B (0-7):", 0, 7, 7, l_mach, 3)
        self.slider_mach_freq = self._create_labeled_slider("Frequency (1-20 Hz):", 1, 20, 10, l_mach, 4)
        self.param_stack.addWidget(p_mach)

        # Page 5: Galloping (start 0-8, stop start+1..9, foot1 0-8, foot2 foot1+1..8, freq 1-8)
        p_gal = QWidget()
        l_gal = QGridLayout(p_gal)
        self.slider_gal_start = self._create_labeled_slider("Travel Start (0-8):", 0, 8, 0, l_gal, 0)
        self.slider_gal_stop = self._create_labeled_slider("Travel Stop (1-9):", 1, 9, 8, l_gal, 1)
        self.slider_gal_f1 = self._create_labeled_slider("Foot 1 Beat (0-8):", 0, 8, 2, l_gal, 2)
        self.slider_gal_f2 = self._create_labeled_slider("Foot 2 Beat (1-8):", 1, 8, 5, l_gal, 3)
        self.slider_gal_freq = self._create_labeled_slider("Cadence Frequency (1-8):", 1, 8, 4, l_gal, 4)
        self.param_stack.addWidget(p_gal)

        # Page 6: Vibration (pos 0-9, amp 1-8, freq 1-40)
        p_vib = QWidget()
        l_vib = QGridLayout(p_vib)
        self.slider_vib_pos = self._create_labeled_slider("Center Position (0-9):", 0, 9, 3, l_vib, 0)
        self.slider_vib_amp = self._create_labeled_slider("Amplitude (1-8):", 1, 8, 6, l_vib, 1)
        self.slider_vib_freq = self._create_labeled_slider("Motor Frequency (1-40 Hz):", 1, 40, 24, l_vib, 2)
        self.param_stack.addWidget(p_vib)

    def _create_labeled_slider(self, label_text: str, min_v: int, max_v: int, def_v: int, grid: QGridLayout, row: int) -> QSlider:
        lbl = QLabel(label_text)
        lbl.setStyleSheet("color: #8b949e; font-size: 11px;")
        val_lbl = QLabel(str(def_v))
        val_lbl.setStyleSheet("font-weight: 600; color: #58a6ff;")
        val_lbl.setFixedWidth(28)

        slider = QSlider(Qt.Orientation.Horizontal)
        slider.setRange(min_v, max_v)
        slider.setValue(def_v)
        slider.valueChanged.connect(lambda v, l=val_lbl: l.setText(str(v)))
        slider.valueChanged.connect(self._update_visualizer_description)

        grid.addWidget(lbl, row, 0)
        grid.addWidget(slider, row, 1)
        grid.addWidget(val_lbl, row, 2)
        return slider

    def _get_target(self) -> TriggerTarget:
        checked_btn = self.target_group.checkedButton()
        if checked_btn:
            return checked_btn.property("target_val")
        return TriggerTarget.BOTH

    def _on_mode_changed(self, index: int):
        self.param_stack.setCurrentIndex(index)
        self._update_visualizer_description()

    def _on_preset_selected(self, index: int):
        preset_id = self.combo_presets.currentData()
        if preset_id == "custom":
            return
        elif preset_id == "off":
            self.combo_mode.setCurrentIndex(0)
        elif preset_id == "handgun":
            self.combo_mode.setCurrentIndex(2)  # Weapon
            self.slider_wp_start.setValue(2)
            self.slider_wp_stop.setValue(5)
            self.slider_wp_str.setValue(7)
        elif preset_id == "shotgun":
            self.combo_mode.setCurrentIndex(2)  # Weapon
            self.slider_wp_start.setValue(3)
            self.slider_wp_stop.setValue(6)
            self.slider_wp_str.setValue(8)
        elif preset_id == "sniper":
            self.combo_mode.setCurrentIndex(1)  # Feedback
            self.slider_fb_pos.setValue(1)
            self.slider_fb_str.setValue(8)
        elif preset_id == "bow":
            self.combo_mode.setCurrentIndex(3)  # Bow
            self.slider_bow_start.setValue(1)
            self.slider_bow_stop.setValue(7)
            self.slider_bow_str.setValue(6)
            self.slider_bow_snap.setValue(8)
        elif preset_id == "machine_gun":
            self.combo_mode.setCurrentIndex(4)  # Machine
            self.slider_mach_start.setValue(1)
            self.slider_mach_stop.setValue(7)
            self.slider_mach_a.setValue(1)
            self.slider_mach_b.setValue(7)
            self.slider_mach_freq.setValue(12)
        elif preset_id == "gallop":
            self.combo_mode.setCurrentIndex(5)  # Galloping
            self.slider_gal_start.setValue(0)
            self.slider_gal_stop.setValue(8)
            self.slider_gal_f1.setValue(2)
            self.slider_gal_f2.setValue(5)
            self.slider_gal_freq.setValue(4)
        elif preset_id == "engine":
            self.combo_mode.setCurrentIndex(6)  # Vibration
            self.slider_vib_pos.setValue(2)
            self.slider_vib_amp.setValue(6)
            self.slider_vib_freq.setValue(24)

        self._update_visualizer_description()

    def _update_visualizer_description(self):
        mode = self.combo_mode.currentData()
        if mode == TriggerMode.OFF:
            self.lbl_viz_desc.setText("Smooth standard trigger pull. No resistance.")
            self.viz_progress.setStyleSheet("QProgressBar::chunk { background-color: #30363d; }")
        elif mode == TriggerMode.FEEDBACK:
            pos = self.slider_fb_pos.value()
            st = self.slider_fb_str.value()
            self.lbl_viz_desc.setText(f"Feedback Wall: Continuous resistance starting at step {pos}/9 with strength {st}/8.")
            self.viz_progress.setStyleSheet("QProgressBar::chunk { background-color: #388bfd; }")
        elif mode == TriggerMode.WEAPON:
            start = self.slider_wp_start.value()
            stop = self.slider_wp_stop.value()
            st = self.slider_wp_str.value()
            self.lbl_viz_desc.setText(f"Gun Trigger: Wall from {start} to {stop}, sharp tactile break with force {st}/8.")
            self.viz_progress.setStyleSheet("QProgressBar::chunk { background-color: #f85149; }")
        elif mode == TriggerMode.BOW:
            start = self.slider_bow_start.value()
            stop = self.slider_bow_stop.value()
            snap = self.slider_bow_snap.value()
            self.lbl_viz_desc.setText(f"Bow Tension: Pull resistance from {start} to {stop}, snaps at release with force {snap}/8.")
            self.viz_progress.setStyleSheet("QProgressBar::chunk { background-color: #e3b341; }")
        elif mode == TriggerMode.MACHINE:
            freq = self.slider_mach_freq.value()
            self.lbl_viz_desc.setText(f"Machine Recoil: Vibrating push-back oscillation at {freq} Hz.")
            self.viz_progress.setStyleSheet("QProgressBar::chunk { background-color: #e040fb; }")
        elif mode == TriggerMode.GALLOPING:
            self.lbl_viz_desc.setText("Galloping: Dual-beat pulse mimicking horse footfalls.")
            self.viz_progress.setStyleSheet("QProgressBar::chunk { background-color: #39d353; }")
        elif mode == TriggerMode.VIBRATION:
            freq = self.slider_vib_freq.value()
            self.lbl_viz_desc.setText(f"Vibration Motor: High-speed arm oscillation at {freq} Hz.")
            self.viz_progress.setStyleSheet("QProgressBar::chunk { background-color: #00f0ff; }")

    def apply_current_trigger_config(self):
        dev_id = self.get_device_id_cb()
        tgt = self._get_target()
        mode = self.combo_mode.currentData()

        if mode == TriggerMode.OFF:
            self.wrapper.set_trigger_off(target=tgt, device_id=dev_id)
        elif mode == TriggerMode.FEEDBACK:
            self.wrapper.set_trigger_feedback(
                position=self.slider_fb_pos.value(),
                strength=self.slider_fb_str.value(),
                target=tgt,
                device_id=dev_id
            )
        elif mode == TriggerMode.WEAPON:
            start = self.slider_wp_start.value()
            stop = max(start + 1, self.slider_wp_stop.value())
            self.wrapper.set_trigger_weapon(
                start=start,
                stop=stop,
                strength=self.slider_wp_str.value(),
                target=tgt,
                device_id=dev_id
            )
        elif mode == TriggerMode.BOW:
            start = self.slider_bow_start.value()
            stop = max(start + 1, self.slider_bow_stop.value())
            self.wrapper.set_trigger_bow(
                start=start,
                stop=stop,
                strength=self.slider_bow_str.value(),
                snap_force=self.slider_bow_snap.value(),
                target=tgt,
                device_id=dev_id
            )
        elif mode == TriggerMode.MACHINE:
            start = self.slider_mach_start.value()
            stop = max(start + 1, self.slider_mach_stop.value())
            self.wrapper.set_trigger_machine(
                start=start,
                stop=stop,
                strength_a=self.slider_mach_a.value(),
                strength_b=self.slider_mach_b.value(),
                frequency=self.slider_mach_freq.value(),
                period=2,
                target=tgt,
                device_id=dev_id
            )
        elif mode == TriggerMode.GALLOPING:
            start = self.slider_gal_start.value()
            stop = max(start + 1, self.slider_gal_stop.value())
            f1 = self.slider_gal_f1.value()
            f2 = max(f1 + 1, self.slider_gal_f2.value())
            self.wrapper.set_trigger_galloping(
                start=start,
                stop=stop,
                first_foot=f1,
                second_foot=f2,
                frequency=self.slider_gal_freq.value(),
                target=tgt,
                device_id=dev_id
            )
        elif mode == TriggerMode.VIBRATION:
            self.wrapper.set_trigger_vibration(
                position=self.slider_vib_pos.value(),
                amplitude=self.slider_vib_amp.value(),
                frequency=self.slider_vib_freq.value(),
                target=tgt,
                device_id=dev_id
            )

    def reset_triggers(self):
        dev_id = self.get_device_id_cb()
        tgt = self._get_target()
        self.combo_presets.setCurrentIndex(self.combo_presets.findData("off"))
        self.combo_mode.setCurrentIndex(0)
        self.wrapper.set_trigger_off(target=tgt, device_id=dev_id)
