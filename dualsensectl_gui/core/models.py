"""
Data models and Enums for dualsensectl-gui.
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import Optional, Dict, Any


class ConnectionType(str, Enum):
    USB = "USB"
    BLUETOOTH = "Bluetooth"
    UNKNOWN = "Unknown"


class BatteryStatus(str, Enum):
    CHARGING = "charging"
    DISCHARGING = "discharging"
    FULL = "full"
    NOT_CHARGING = "not-charging"
    UNKNOWN = "unknown"


@dataclass
class BatteryInfo:
    percentage: int = 0
    status: BatteryStatus = BatteryStatus.UNKNOWN
    status_text: str = "Unknown"

    @property
    def is_charging(self) -> bool:
        return self.status == BatteryStatus.CHARGING

    @property
    def is_full(self) -> bool:
        return self.status == BatteryStatus.FULL or self.percentage >= 100


@dataclass
class ControllerDevice:
    device_id: str
    connection_type: ConnectionType = ConnectionType.UNKNOWN
    battery: Optional[BatteryInfo] = None
    is_connected: bool = True

    @property
    def display_name(self) -> str:
        return f"DualSense ({self.device_id}) - {self.connection_type.value}"


class TriggerTarget(str, Enum):
    LEFT = "left"
    RIGHT = "right"
    BOTH = "both"


class TriggerMode(str, Enum):
    OFF = "off"
    FEEDBACK = "feedback"
    WEAPON = "weapon"
    BOW = "bow"
    GALLOPING = "galloping"
    MACHINE = "machine"
    VIBRATION = "vibration"


@dataclass
class TriggerConfig:
    target: TriggerTarget = TriggerTarget.BOTH
    mode: TriggerMode = TriggerMode.OFF
    params: Dict[str, Any] = field(default_factory=dict)


class MicState(str, Enum):
    ON = "on"
    OFF = "off"


class MicLedState(str, Enum):
    ON = "on"
    OFF = "off"
    PULSE = "pulse"


class MicMode(str, Enum):
    CHAT = "chat"
    ASR = "asr"
    BOTH = "both"


class SpeakerMode(str, Enum):
    INTERNAL = "internal"
    HEADPHONE = "headphone"
    BOTH = "both"


@dataclass
class FirmwareInfo:
    hardware: str = ""
    build_date: str = ""
    firmware: str = ""
    fw_version: str = ""
    sw_series: str = ""
    update_version: str = ""
    raw_text: str = ""
