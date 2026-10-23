"""
Subprocess wrapper for the dualsensectl Linux CLI utility.
Provides strongly-typed functions for all DualSense controller features
with error handling, device targeting, and simulated demo mode support.
"""

import logging
import os
import re
import shutil
import subprocess
from typing import List, Optional, Tuple, Dict, Any

from .models import (
    BatteryInfo,
    BatteryStatus,
    ConnectionType,
    ControllerDevice,
    FirmwareInfo,
    MicLedState,
    MicMode,
    MicState,
    SpeakerMode,
    TriggerConfig,
    TriggerMode,
    TriggerTarget,
)

logger = logging.getLogger(__name__)


class DualSenseCTLWrapper:
    """Wrapper around the 'dualsensectl' command line utility."""

    def __init__(self, executable_path: Optional[str] = None, simulation_mode: bool = False):
        self.executable_path = executable_path or shutil.which("dualsensectl") or "dualsensectl"
        self.simulation_mode = simulation_mode
        self._command_history: List[str] = []

        # Mock state for simulation mode
        self._sim_battery = BatteryInfo(percentage=84, status=BatteryStatus.DISCHARGING, status_text="discharging")
        self._sim_devices = [
            ControllerDevice(device_id="hidraw0", connection_type=ConnectionType.BLUETOOTH, battery=self._sim_battery)
        ]
        self._sim_mic_muted = False
        self._sim_lightbar_rgb = (0, 112, 209)  # Sony PS5 Blue

    @property
    def is_installed(self) -> bool:
        """Check if dualsensectl is available on the system."""
        return shutil.which(self.executable_path) is not None

    def execute_raw(self, args: List[str], device_id: Optional[str] = None) -> Tuple[int, str, str]:
        """
        Executes a dualsensectl command with optional device targeting.
        Returns: (returncode, stdout, stderr)
        """
        cmd = [self.executable_path]
        if device_id:
            cmd.extend(["-d", device_id])
        cmd.extend(args)

        cmd_str = " ".join(cmd)
        self._command_history.append(cmd_str)
        logger.debug(f"Executing: {cmd_str}")

        if self.simulation_mode:
            logger.info(f"[SIMULATION] {cmd_str}")
            return (0, "OK (simulated)", "")

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=5.0,
                check=False
            )
            return (result.returncode, result.stdout.strip(), result.stderr.strip())
        except subprocess.TimeoutExpired:
            logger.error(f"Command timed out: {cmd_str}")
            return (-1, "", "Command timed out")
        except FileNotFoundError:
            logger.error(f"Executable not found: {self.executable_path}")
            return (-1, "", f"dualsensectl binary not found at '{self.executable_path}'")
        except Exception as e:
            logger.error(f"Unexpected error running command {cmd_str}: {e}")
            return (-1, "", str(e))

    def list_devices(self) -> List[ControllerDevice]:
        """
        Lists all connected DualSense devices.
        dualsensectl -l output pattern:
        Devices:
          hidraw0 (Bluetooth)
          hidraw1 (USB)
        """
        if self.simulation_mode:
            return list(self._sim_devices)

        rc, stdout, stderr = self.execute_raw(["-l"])
        if rc != 0 and "No devices found" in (stderr + stdout):
            return []

        devices: List[ControllerDevice] = []
        full_text = f"{stdout}\n{stderr}"
        lines = full_text.splitlines()

        # Parse lines like " hidraw0 (Bluetooth)" or " /dev/hidraw1 (USB)"
        device_regex = re.compile(r"^\s*(\S+)\s*\(([^)]+)\)")
        for line in lines:
            line_clean = line.strip()
            if not line_clean or line_clean.startswith("Devices:"):
                continue
            match = device_regex.match(line_clean)
            if match:
                dev_id = match.group(1).replace("/dev/", "")
                conn_str = match.group(2).lower()
                conn_type = (
                    ConnectionType.BLUETOOTH if "bluetooth" in conn_str
                    else ConnectionType.USB if "usb" in conn_str
                    else ConnectionType.UNKNOWN
                )
                dev = ControllerDevice(device_id=dev_id, connection_type=conn_type)
                devices.append(dev)

        return devices

    def get_battery(self, device_id: Optional[str] = None) -> Optional[BatteryInfo]:
        """
        Queries the battery level and status.
        dualsensectl battery output pattern:
        '80 discharging' or '100 full' or '45 charging' or '80 not-charging'
        """
        if self.simulation_mode:
            return self._sim_battery

        rc, stdout, stderr = self.execute_raw(["battery"], device_id=device_id)
        if rc != 0:
            logger.warning(f"Failed to get battery: {stderr or stdout}")
            return None

        # Expect format: "%d %s"
        parts = stdout.split()
        if not parts:
            return None

        try:
            pct = int(parts[0])
            status_str = parts[1].lower() if len(parts) > 1 else "unknown"

            if status_str == "charging":
                status = BatteryStatus.CHARGING
            elif status_str == "not-charging":
                status = BatteryStatus.NOT_CHARGING
            elif status_str == "full":
                status = BatteryStatus.FULL
            elif status_str == "discharging":
                status = BatteryStatus.DISCHARGING
            else:
                status = BatteryStatus.UNKNOWN

            return BatteryInfo(percentage=pct, status=status, status_text=status_str)
        except (ValueError, IndexError) as e:
            logger.error(f"Failed to parse battery output '{stdout}': {e}")
            return None

    def get_firmware_info(self, device_id: Optional[str] = None) -> Optional[FirmwareInfo]:
        """
        Queries controller firmware and hardware info via 'dualsensectl info'.
        """
        if self.simulation_mode:
            return FirmwareInfo(
                hardware="0x03",
                build_date="Oct 20 2024 14:22:00",
                firmware="0x0284 (type 0)",
                fw_version="2 134 0",
                sw_series="3",
                update_version="0x0000",
                raw_text="[Simulation Mode DualSense Controller]"
            )

        rc, stdout, stderr = self.execute_raw(["info"], device_id=device_id)
        if rc != 0:
            return None

        info = FirmwareInfo(raw_text=stdout)
        for line in stdout.splitlines():
            if ":" not in line:
                continue
            k, v = [part.strip() for part in line.split(":", 1)]
            k_lower = k.lower()
            if "hardware" in k_lower:
                info.hardware = v
            elif "build date" in k_lower:
                info.build_date = v
            elif "firmware" in k_lower:
                info.firmware = v
            elif "fw version" in k_lower:
                info.fw_version = v
            elif "sw series" in k_lower:
                info.sw_series = v
            elif "update version" in k_lower:
                info.update_version = v

        return info

    def set_lightbar_state(self, enabled: bool, device_id: Optional[str] = None) -> bool:
        """Enable (on) or disable (off) lightbar."""
        state_str = "on" if enabled else "off"
        rc, _, _ = self.execute_raw(["lightbar", state_str], device_id=device_id)
        return rc == 0

    def set_lightbar_color(
        self,
        r: int,
        g: int,
        b: int,
        brightness: Optional[int] = None,
        device_id: Optional[str] = None
    ) -> bool:
        """
        Set RGB lightbar color (0-255) and optional brightness (0-255).
        dualsensectl lightbar RED GREEN BLUE [BRIGHTNESS]
        """
        r = max(0, min(255, int(r)))
        g = max(0, min(255, int(g)))
        b = max(0, min(255, int(b)))

        args = ["lightbar", str(r), str(g), str(b)]
        if brightness is not None:
            br = max(0, min(255, int(brightness)))
            args.append(str(br))

        if self.simulation_mode:
            self._sim_lightbar_rgb = (r, g, b)

        rc, _, _ = self.execute_raw(args, device_id=device_id)
        return rc == 0

    def set_led_brightness(self, level: int, device_id: Optional[str] = None) -> bool:
        """
        Set player and microphone LED dimming (0=bright, 1=medium, 2=dim).
        """
        level = max(0, min(2, int(level)))
        rc, _, _ = self.execute_raw(["led-brightness", str(level)], device_id=device_id)
        return rc == 0

    def set_player_leds(self, player_number: int, instant: bool = False, device_id: Optional[str] = None) -> bool:
        """
        Set player LEDs (1-5/7) or disabled (0).
        Optional instant parameter applies without fade.
        """
        num = max(0, min(7, int(player_number)))
        args = ["player-leds", str(num)]
        if instant:
            args.append("instant")
        rc, _, _ = self.execute_raw(args, device_id=device_id)
        return rc == 0

    def set_microphone(self, enabled: bool, device_id: Optional[str] = None) -> bool:
        """Enable ('on') or disable ('off') controller microphone."""
        state_str = "on" if enabled else "off"
        if self.simulation_mode:
            self._sim_mic_muted = not enabled
        rc, _, _ = self.execute_raw(["microphone", state_str], device_id=device_id)
        return rc == 0

    def set_microphone_led(self, state: MicLedState, device_id: Optional[str] = None) -> bool:
        """Enable ('on'), disable ('off') or pulsate ('pulse') microphone LED."""
        val = state.value if isinstance(state, MicLedState) else str(state)
        rc, _, _ = self.execute_raw(["microphone-led", val], device_id=device_id)
        return rc == 0

    def set_microphone_mode(self, mode: MicMode, device_id: Optional[str] = None) -> bool:
        """Toggle microphone usage to 'chat', 'asr' or 'both'."""
        val = mode.value if isinstance(mode, MicMode) else str(mode)
        rc, _, _ = self.execute_raw(["microphone-mode", val], device_id=device_id)
        return rc == 0

    def set_speaker(self, state: SpeakerMode, device_id: Optional[str] = None) -> bool:
        """Toggle speaker to 'internal', 'headphone' or 'both'."""
        val = state.value if isinstance(state, SpeakerMode) else str(state)
        rc, _, _ = self.execute_raw(["speaker", val], device_id=device_id)
        return rc == 0

    def set_volume(self, volume: int, device_id: Optional[str] = None) -> bool:
        """Set audio volume (0-255)."""
        vol = max(0, min(255, int(volume)))
        rc, _, _ = self.execute_raw(["volume", str(vol)], device_id=device_id)
        return rc == 0

    def set_attenuation(self, rumble: int, trigger: int, device_id: Optional[str] = None) -> bool:
        """Set attenuation (0-7) for rumble motors and trigger vibration."""
        rumble = max(0, min(7, int(rumble)))
        trigger = max(0, min(7, int(trigger)))
        rc, _, _ = self.execute_raw(["attenuation", str(rumble), str(trigger)], device_id=device_id)
        return rc == 0

    def set_trigger_off(self, target: TriggerTarget = TriggerTarget.BOTH, device_id: Optional[str] = None) -> bool:
        """Remove all active adaptive trigger effects."""
        tgt = target.value if isinstance(target, TriggerTarget) else str(target)
        rc, _, _ = self.execute_raw(["trigger", tgt, "off"], device_id=device_id)
        return rc == 0

    def set_trigger_feedback(
        self,
        position: int,
        strength: int,
        target: TriggerTarget = TriggerTarget.BOTH,
        device_id: Optional[str] = None
    ) -> bool:
        """
        Feedback mode: Set resistance starting at position with defined strength.
        position: 0 to 9
        strength: 1 to 8
        """
        tgt = target.value if isinstance(target, TriggerTarget) else str(target)
        pos = max(0, min(9, int(position)))
        st = max(1, min(8, int(strength)))
        rc, _, _ = self.execute_raw(["trigger", tgt, "feedback", str(pos), str(st)], device_id=device_id)
        return rc == 0

    def set_trigger_weapon(
        self,
        start: int,
        stop: int,
        strength: int,
        target: TriggerTarget = TriggerTarget.BOTH,
        device_id: Optional[str] = None
    ) -> bool:
        """
        Weapon mode: Emulates firearm trigger break and reset.
        start: 2 to 7
        stop: (start+1) to 8
        strength: 1 to 8
        """
        tgt = target.value if isinstance(target, TriggerTarget) else str(target)
        start_val = max(2, min(7, int(start)))
        stop_val = max(start_val + 1, min(8, int(stop)))
        str_val = max(1, min(8, int(strength)))
        rc, _, _ = self.execute_raw(["trigger", tgt, "weapon", str(start_val), str(stop_val), str(str_val)], device_id=device_id)
        return rc == 0

    def set_trigger_bow(
        self,
        start: int,
        stop: int,
        strength: int,
        snap_force: int,
        target: TriggerTarget = TriggerTarget.BOTH,
        device_id: Optional[str] = None
    ) -> bool:
        """
        Bow mode: Emulates drawing tension with snap release.
        start: 0 to 8
        stop: (start+1) to 8
        strength: 1 to 8
        snap_force: 1 to 8
        """
        tgt = target.value if isinstance(target, TriggerTarget) else str(target)
        start_val = max(0, min(8, int(start)))
        stop_val = max(start_val + 1, min(8, int(stop)))
        str_val = max(1, min(8, int(strength)))
        snap_val = max(1, min(8, int(snap_force)))
        rc, _, _ = self.execute_raw(
            ["trigger", tgt, "bow", str(start_val), str(stop_val), str(str_val), str(snap_val)],
            device_id=device_id
        )
        return rc == 0

    def set_trigger_galloping(
        self,
        start: int,
        stop: int,
        first_foot: int,
        second_foot: int,
        frequency: int,
        target: TriggerTarget = TriggerTarget.BOTH,
        device_id: Optional[str] = None
    ) -> bool:
        """
        Galloping mode: Emulates horse gallop rhythm.
        start: 0 to 8
        stop: (start+1) to 9
        first_foot: 0 to 8
        second_foot: (first_foot+1) to 8
        frequency: > 0 (1 to 8 recommended)
        """
        tgt = target.value if isinstance(target, TriggerTarget) else str(target)
        start_val = max(0, min(8, int(start)))
        stop_val = max(start_val + 1, min(9, int(stop)))
        f1 = max(0, min(8, int(first_foot)))
        f2 = max(f1 + 1, min(8, int(second_foot)))
        freq = max(1, min(20, int(frequency)))
        rc, _, _ = self.execute_raw(
            ["trigger", tgt, "galloping", str(start_val), str(stop_val), str(f1), str(f2), str(freq)],
            device_id=device_id
        )
        return rc == 0

    def set_trigger_machine(
        self,
        start: int,
        stop: int,
        strength_a: int,
        strength_b: int,
        frequency: int,
        period: int,
        target: TriggerTarget = TriggerTarget.BOTH,
        device_id: Optional[str] = None
    ) -> bool:
        """
        Machine mode: Switches vibration between two strengths at a specified period.
        start: 1 to 8
        stop: (start+1) to 8
        strength_a: 0 to 7
        strength_b: 0 to 7
        frequency: 1 to 20
        period: 1 to 10
        """
        tgt = target.value if isinstance(target, TriggerTarget) else str(target)
        start_val = max(1, min(8, int(start)))
        stop_val = max(start_val + 1, min(8, int(stop)))
        s_a = max(0, min(7, int(strength_a)))
        s_b = max(0, min(7, int(strength_b)))
        freq = max(1, min(40, int(frequency)))
        per = max(1, min(20, int(period)))
        rc, _, _ = self.execute_raw(
            ["trigger", tgt, "machine", str(start_val), str(stop_val), str(s_a), str(s_b), str(freq), str(per)],
            device_id=device_id
        )
        return rc == 0

    def set_trigger_vibration(
        self,
        position: int,
        amplitude: int,
        frequency: int,
        target: TriggerTarget = TriggerTarget.BOTH,
        device_id: Optional[str] = None
    ) -> bool:
        """
        Vibration mode: Vibrates motor arm around specified position.
        position: 0 to 9
        amplitude: 1 to 8
        frequency: 1 to 40
        """
        tgt = target.value if isinstance(target, TriggerTarget) else str(target)
        pos = max(0, min(9, int(position)))
        amp = max(1, min(8, int(amplitude)))
        freq = max(1, min(40, int(frequency)))
        rc, _, _ = self.execute_raw(
            ["trigger", tgt, "vibration", str(pos), str(amp), str(freq)],
            device_id=device_id
        )
        return rc == 0

    def power_off(self, device_id: Optional[str] = None) -> bool:
        """Turn off the controller (Bluetooth only)."""
        rc, _, _ = self.execute_raw(["power-off"], device_id=device_id)
        return rc == 0
