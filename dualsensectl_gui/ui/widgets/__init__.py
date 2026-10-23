"""
UI Widgets package for dualsensectl-gui.
"""

from .device_header import DeviceHeaderWidget
from .battery_widget import BatteryWidget
from .lightbar_widget import LightbarWidget
from .audio_mic_widget import AudioMicWidget
from .triggers_widget import TriggersWidget

__all__ = [
    "DeviceHeaderWidget",
    "BatteryWidget",
    "LightbarWidget",
    "AudioMicWidget",
    "TriggersWidget",
]
