#include "DualSenseDevice.h"

DualSenseDevice::DualSenseDevice(QObject *parent)
    : QObject(parent)
{
}

void DualSenseDevice::setId(const QString &id) {
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void DualSenseDevice::setName(const QString &name) {
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}

void DualSenseDevice::setConnectionType(const QString &type) {
    if (m_connectionType != type) {
        m_connectionType = type;
        emit connectionTypeChanged();
    }
}

void DualSenseDevice::setBatteryPercent(int percent) {
    int clamped = qBound(0, percent, 100);
    if (m_batteryPercent != clamped) {
        m_batteryPercent = clamped;
        emit batteryPercentChanged();
    }
}

void DualSenseDevice::setBatteryStatus(const QString &status) {
    if (m_batteryStatus != status) {
        m_batteryStatus = status;
        emit batteryStatusChanged();
        emit isChargingChanged();
    }
}

void DualSenseDevice::setFirmwareVersion(const QString &version) {
    if (m_firmwareVersion != version) {
        m_firmwareVersion = version;
        emit firmwareVersionChanged();
    }
}

void DualSenseDevice::setBuildNumber(const QString &build) {
    if (m_buildNumber != build) {
        m_buildNumber = build;
        emit buildNumberChanged();
    }
}

void DualSenseDevice::setLightbarColor(const QColor &color) {
    if (m_lightbarColor != color) {
        m_lightbarColor = color;
        emit lightbarColorChanged();
    }
}

void DualSenseDevice::setLightbarBrightness(int brightness) {
    int clamped = qBound(0, brightness, 255);
    if (m_lightbarBrightness != clamped) {
        m_lightbarBrightness = clamped;
        emit lightbarBrightnessChanged();
    }
}

void DualSenseDevice::setLightbarEnabled(bool enabled) {
    if (m_lightbarEnabled != enabled) {
        m_lightbarEnabled = enabled;
        emit lightbarEnabledChanged();
    }
}

void DualSenseDevice::setPlayerLeds(int leds) {
    int clamped = qBound(0, leds, 7);
    if (m_playerLeds != clamped) {
        m_playerLeds = clamped;
        emit playerLedsChanged();
    }
}

void DualSenseDevice::setLedBrightness(int level) {
    int clamped = qBound(0, level, 2);
    if (m_ledBrightness != clamped) {
        m_ledBrightness = clamped;
        emit ledBrightnessChanged();
    }
}

void DualSenseDevice::setMicMuted(bool muted) {
    if (m_micMuted != muted) {
        m_micMuted = muted;
        emit micMutedChanged();
    }
}

void DualSenseDevice::setMicLedState(const QString &state) {
    if (m_micLedState != state) {
        m_micLedState = state;
        emit micLedStateChanged();
    }
}

void DualSenseDevice::setMicMode(const QString &mode) {
    if (m_micMode != mode) {
        m_micMode = mode;
        emit micModeChanged();
    }
}

void DualSenseDevice::setSpeakerMode(const QString &mode) {
    if (m_speakerMode != mode) {
        m_speakerMode = mode;
        emit speakerModeChanged();
    }
}

void DualSenseDevice::setVolume(int volume) {
    int clamped = qBound(0, volume, 255);
    if (m_volume != clamped) {
        m_volume = clamped;
        emit volumeChanged();
    }
}

void DualSenseDevice::setRumbleAttenuation(int att) {
    int clamped = qBound(0, att, 7);
    if (m_rumbleAttenuation != clamped) {
        m_rumbleAttenuation = clamped;
        emit rumbleAttenuationChanged();
    }
}

void DualSenseDevice::setTriggerAttenuation(int att) {
    int clamped = qBound(0, att, 7);
    if (m_triggerAttenuation != clamped) {
        m_triggerAttenuation = clamped;
        emit triggerAttenuationChanged();
    }
}

void DualSenseDevice::setLeftTriggerMode(const QString &mode) {
    if (m_leftTriggerMode != mode) {
        m_leftTriggerMode = mode;
        emit leftTriggerModeChanged();
    }
}

void DualSenseDevice::setRightTriggerMode(const QString &mode) {
    if (m_rightTriggerMode != mode) {
        m_rightTriggerMode = mode;
        emit rightTriggerModeChanged();
    }
}

void DualSenseDevice::setLeftTriggerSummary(const QString &summary) {
    if (m_leftTriggerSummary != summary) {
        m_leftTriggerSummary = summary;
        emit leftTriggerSummaryChanged();
    }
}

void DualSenseDevice::setRightTriggerSummary(const QString &summary) {
    if (m_rightTriggerSummary != summary) {
        m_rightTriggerSummary = summary;
        emit rightTriggerSummaryChanged();
    }
}
