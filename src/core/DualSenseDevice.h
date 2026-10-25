#pragma once

#include <QObject>
#include <QString>
#include <QColor>
#include <QVariantMap>

class DualSenseDevice : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString connectionType READ connectionType WRITE setConnectionType NOTIFY connectionTypeChanged)
    Q_PROPERTY(int batteryPercent READ batteryPercent WRITE setBatteryPercent NOTIFY batteryPercentChanged)
    Q_PROPERTY(QString batteryStatus READ batteryStatus WRITE setBatteryStatus NOTIFY batteryStatusChanged)
    Q_PROPERTY(bool isCharging READ isCharging NOTIFY isChargingChanged)
    Q_PROPERTY(QString firmwareVersion READ firmwareVersion WRITE setFirmwareVersion NOTIFY firmwareVersionChanged)
    Q_PROPERTY(QString buildNumber READ buildNumber WRITE setBuildNumber NOTIFY buildNumberChanged)

    Q_PROPERTY(QColor lightbarColor READ lightbarColor WRITE setLightbarColor NOTIFY lightbarColorChanged)
    Q_PROPERTY(int lightbarBrightness READ lightbarBrightness WRITE setLightbarBrightness NOTIFY lightbarBrightnessChanged)
    Q_PROPERTY(bool lightbarEnabled READ lightbarEnabled WRITE setLightbarEnabled NOTIFY lightbarEnabledChanged)
    Q_PROPERTY(int playerLeds READ playerLeds WRITE setPlayerLeds NOTIFY playerLedsChanged)
    Q_PROPERTY(int ledBrightness READ ledBrightness WRITE setLedBrightness NOTIFY ledBrightnessChanged)

    Q_PROPERTY(bool micMuted READ micMuted WRITE setMicMuted NOTIFY micMutedChanged)
    Q_PROPERTY(QString micLedState READ micLedState WRITE setMicLedState NOTIFY micLedStateChanged)
    Q_PROPERTY(QString micMode READ micMode WRITE setMicMode NOTIFY micModeChanged)
    Q_PROPERTY(QString speakerMode READ speakerMode WRITE setSpeakerMode NOTIFY speakerModeChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(int rumbleAttenuation READ rumbleAttenuation WRITE setRumbleAttenuation NOTIFY rumbleAttenuationChanged)
    Q_PROPERTY(int triggerAttenuation READ triggerAttenuation WRITE setTriggerAttenuation NOTIFY triggerAttenuationChanged)

    Q_PROPERTY(QString leftTriggerMode READ leftTriggerMode WRITE setLeftTriggerMode NOTIFY leftTriggerModeChanged)
    Q_PROPERTY(QString rightTriggerMode READ rightTriggerMode WRITE setRightTriggerMode NOTIFY rightTriggerModeChanged)
    Q_PROPERTY(QString leftTriggerSummary READ leftTriggerSummary WRITE setLeftTriggerSummary NOTIFY leftTriggerSummaryChanged)
    Q_PROPERTY(QString rightTriggerSummary READ rightTriggerSummary WRITE setRightTriggerSummary NOTIFY rightTriggerSummaryChanged)

public:
    explicit DualSenseDevice(QObject *parent = nullptr);

    QString id() const { return m_id; }
    void setId(const QString &id);

    QString name() const { return m_name; }
    void setName(const QString &name);

    QString connectionType() const { return m_connectionType; }
    void setConnectionType(const QString &type);

    int batteryPercent() const { return m_batteryPercent; }
    void setBatteryPercent(int percent);

    QString batteryStatus() const { return m_batteryStatus; }
    void setBatteryStatus(const QString &status);

    bool isCharging() const { return m_batteryStatus == "charging"; }

    QString firmwareVersion() const { return m_firmwareVersion; }
    void setFirmwareVersion(const QString &version);

    QString buildNumber() const { return m_buildNumber; }
    void setBuildNumber(const QString &build);

    QColor lightbarColor() const { return m_lightbarColor; }
    void setLightbarColor(const QColor &color);

    int lightbarBrightness() const { return m_lightbarBrightness; }
    void setLightbarBrightness(int brightness);

    bool lightbarEnabled() const { return m_lightbarEnabled; }
    void setLightbarEnabled(bool enabled);

    int playerLeds() const { return m_playerLeds; }
    void setPlayerLeds(int leds);

    int ledBrightness() const { return m_ledBrightness; }
    void setLedBrightness(int level);

    bool micMuted() const { return m_micMuted; }
    void setMicMuted(bool muted);

    QString micLedState() const { return m_micLedState; }
    void setMicLedState(const QString &state);

    QString micMode() const { return m_micMode; }
    void setMicMode(const QString &mode);

    QString speakerMode() const { return m_speakerMode; }
    void setSpeakerMode(const QString &mode);

    int volume() const { return m_volume; }
    void setVolume(int volume);

    int rumbleAttenuation() const { return m_rumbleAttenuation; }
    void setRumbleAttenuation(int att);

    int triggerAttenuation() const { return m_triggerAttenuation; }
    void setTriggerAttenuation(int att);

    QString leftTriggerMode() const { return m_leftTriggerMode; }
    void setLeftTriggerMode(const QString &mode);

    QString rightTriggerMode() const { return m_rightTriggerMode; }
    void setRightTriggerMode(const QString &mode);

    QString leftTriggerSummary() const { return m_leftTriggerSummary; }
    void setLeftTriggerSummary(const QString &summary);

    QString rightTriggerSummary() const { return m_rightTriggerSummary; }
    void setRightTriggerSummary(const QString &summary);

signals:
    void idChanged();
    void nameChanged();
    void connectionTypeChanged();
    void batteryPercentChanged();
    void batteryStatusChanged();
    void isChargingChanged();
    void firmwareVersionChanged();
    void buildNumberChanged();
    void lightbarColorChanged();
    void lightbarBrightnessChanged();
    void lightbarEnabledChanged();
    void playerLedsChanged();
    void ledBrightnessChanged();
    void micMutedChanged();
    void micLedStateChanged();
    void micModeChanged();
    void speakerModeChanged();
    void volumeChanged();
    void rumbleAttenuationChanged();
    void triggerAttenuationChanged();
    void leftTriggerModeChanged();
    void rightTriggerModeChanged();
    void leftTriggerSummaryChanged();
    void rightTriggerSummaryChanged();

private:
    QString m_id;
    QString m_name{"DualSense Wireless Controller"};
    QString m_connectionType{"Bluetooth"};
    int m_batteryPercent{85};
    QString m_batteryStatus{"discharging"};
    QString m_firmwareVersion{"0307.0014"};
    QString m_buildNumber{"0x00000000"};

    QColor m_lightbarColor{QColor("#388BFF")}; // Expressive Blue
    int m_lightbarBrightness{255};
    bool m_lightbarEnabled{true};
    int m_playerLeds{1};
    int m_ledBrightness{0};

    bool m_micMuted{false};
    QString m_micLedState{"off"};
    QString m_micMode{"chat"};
    QString m_speakerMode{"both"};
    int m_volume{200};
    int m_rumbleAttenuation{0};
    int m_triggerAttenuation{0};

    QString m_leftTriggerMode{"off"};
    QString m_rightTriggerMode{"off"};
    QString m_leftTriggerSummary{"Standard Smooth Resistance"};
    QString m_rightTriggerSummary{"Standard Smooth Resistance"};
};
