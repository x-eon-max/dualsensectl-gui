#pragma once

#include <QObject>
#include <QList>
#include <QString>
#include <QTimer>
#include <QProcess>
#include "DualSenseDevice.h"

class DualSenseClient : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool simulationMode READ isSimulationMode WRITE setSimulationMode NOTIFY simulationModeChanged)
    Q_PROPERTY(bool isInstalled READ isInstalled CONSTANT)
    Q_PROPERTY(QString executablePath READ executablePath CONSTANT)
    Q_PROPERTY(DualSenseDevice* activeDevice READ activeDevice NOTIFY activeDeviceChanged)
    Q_PROPERTY(int deviceCount READ deviceCount NOTIFY devicesChanged)
    Q_PROPERTY(int activeIndex READ activeIndex WRITE setActiveIndex NOTIFY activeIndexChanged)

public:
    explicit DualSenseClient(QObject *parent = nullptr);
    ~DualSenseClient();

    bool isSimulationMode() const { return m_simulationMode; }
    void setSimulationMode(bool sim);

    bool isInstalled() const;
    QString executablePath() const { return m_executablePath; }

    DualSenseDevice* activeDevice() const;
    int deviceCount() const { return m_devices.size(); }
    int activeIndex() const { return m_activeIndex; }
    void setActiveIndex(int index);

    Q_INVOKABLE void rescan();
    Q_INVOKABLE void toggleSimulationMode();

    // Hardware commands invokable from QML
    Q_INVOKABLE bool setLightbar(int r, int g, int b, int brightness = 255);
    Q_INVOKABLE bool setLightbarEnabled(bool enabled);
    Q_INVOKABLE bool setPlayerLeds(int leds, bool instant = false);
    Q_INVOKABLE bool setLedBrightness(int level);

    Q_INVOKABLE bool setMicMuted(bool muted);
    Q_INVOKABLE bool setMicLed(const QString &state);
    Q_INVOKABLE bool setMicMode(const QString &mode);
    Q_INVOKABLE bool setSpeakerMode(const QString &mode);
    Q_INVOKABLE bool setVolume(int volume);
    Q_INVOKABLE bool setAttenuation(int rumble, int trigger);

    // Adaptive triggers
    Q_INVOKABLE bool setTriggerOff(const QString &target = "both");
    Q_INVOKABLE bool setTriggerFeedback(const QString &target, int position, int strength);
    Q_INVOKABLE bool setTriggerWeapon(const QString &target, int start, int stop, int strength);
    Q_INVOKABLE bool setTriggerBow(const QString &target, int start, int stop, int strength, int snapforce);
    Q_INVOKABLE bool setTriggerGalloping(const QString &target, int start, int stop, int foot1, int foot2, int freq);
    Q_INVOKABLE bool setTriggerMachine(const QString &target, int start, int stop, int strA, int strB, int freq, int period);
    Q_INVOKABLE bool setTriggerVibration(const QString &target, int pos, int amp, int freq);

    Q_INVOKABLE bool powerOff();

signals:
    void simulationModeChanged();
    void devicesChanged();
    void activeDeviceChanged();
    void activeIndexChanged();
    void toastRequested(const QString &message, const QString &type);
    void commandExecuted(const QString &cmd, bool success, const QString &output);

private slots:
    void onPollTimer();

private:
    struct ExecResult {
        int exitCode;
        QString stdOut;
        QString stdErr;
        bool success() const { return exitCode == 0; }
    };

    ExecResult runCli(const QStringList &args, const QString &deviceId = QString());
    void populateSimulatedDevice();
    void updateBatteryForDevice(DualSenseDevice *device);
    void updateFirmwareForDevice(DualSenseDevice *device);

    QString m_executablePath;
    bool m_simulationMode{false};
    QList<DualSenseDevice*> m_devices;
    int m_activeIndex{0};
    QTimer *m_pollTimer{nullptr};
};
