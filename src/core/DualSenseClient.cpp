#include "DualSenseClient.h"
#include <QStandardPaths>
#include <QRegularExpression>
#include <QFile>
#include <QDebug>
#include <algorithm>

DualSenseClient::DualSenseClient(QObject *parent)
    : QObject(parent)
{
    m_executablePath = QStandardPaths::findExecutable("dualsensectl");
    if (m_executablePath.isEmpty()) {
        m_executablePath = "/usr/bin/dualsensectl";
    }

    m_pollTimer = new QTimer(this);
    m_pollTimer->setInterval(3000); // Poll every 3 seconds
    connect(m_pollTimer, &QTimer::timeout, this, &DualSenseClient::onPollTimer);

    // Initial scan
    rescan();

    // Start background poll timer
    m_pollTimer->start();
}

DualSenseClient::~DualSenseClient() {
    qDeleteAll(m_devices);
    m_devices.clear();
}

bool DualSenseClient::isInstalled() const {
    return !m_executablePath.isEmpty() && QFile::exists(m_executablePath);
}

DualSenseDevice* DualSenseClient::activeDevice() const {
    if (m_devices.isEmpty() || m_activeIndex < 0 || m_activeIndex >= m_devices.size()) {
        return nullptr;
    }
    return m_devices.at(m_activeIndex);
}

void DualSenseClient::setActiveIndex(int index) {
    if (index >= 0 && index < m_devices.size() && index != m_activeIndex) {
        m_activeIndex = index;
        emit activeIndexChanged();
        emit activeDeviceChanged();
    }
}

void DualSenseClient::setSimulationMode(bool sim) {
    if (m_simulationMode != sim) {
        m_simulationMode = sim;
        emit simulationModeChanged();
        rescan();
    }
}

void DualSenseClient::toggleSimulationMode() {
    setSimulationMode(!m_simulationMode);
    emit toastRequested(m_simulationMode ? "Mode Démo / Simulation activé" : "Recherche de contrôleur physique...", "info");
}

DualSenseClient::ExecResult DualSenseClient::runCli(const QStringList &args, const QString &deviceId) {
    ExecResult res;
    res.exitCode = -1;

    if (m_simulationMode) {
        res.exitCode = 0;
        res.stdOut = "OK (simulated)";
        return res;
    }

    if (!isInstalled()) {
        res.stdErr = "dualsensectl introuvable sur le système.";
        return res;
    }

    QStringList fullArgs;
    if (!deviceId.isEmpty()) {
        fullArgs << "-d" << deviceId;
    }
    fullArgs << args;

    QProcess process;
    process.start(m_executablePath, fullArgs);
    if (!process.waitForStarted(2000)) {
        res.stdErr = "Impossible de lancer dualsensectl.";
        return res;
    }

    if (!process.waitForFinished(4000)) {
        process.kill();
        res.stdErr = "Timeout lors de l'exécution de dualsensectl.";
        return res;
    }

    res.exitCode = process.exitCode();
    res.stdOut = QString::fromUtf8(process.readAllStandardOutput()).trimmed();
    res.stdErr = QString::fromUtf8(process.readAllStandardError()).trimmed();

    emit commandExecuted(m_executablePath + " " + fullArgs.join(" "), res.success(), res.stdOut);
    return res;
}

void DualSenseClient::populateSimulatedDevice() {
    qDeleteAll(m_devices);
    m_devices.clear();

    DualSenseDevice *sim = new DualSenseDevice(this);
    sim->setId("sim-hidraw0");
    sim->setName("DualSense Edge (Simulateur M3)");
    sim->setConnectionType("Bluetooth");
    sim->setBatteryPercent(88);
    sim->setBatteryStatus("discharging");
    sim->setFirmwareVersion("0307.0014");
    sim->setBuildNumber("0x00000000");
    sim->setLightbarColor(QColor("#388BFF"));
    sim->setLightbarBrightness(255);
    sim->setPlayerLeds(1);
    sim->setMicMuted(false);
    sim->setVolume(220);

    m_devices.append(sim);
    m_activeIndex = 0;

    emit devicesChanged();
    emit activeIndexChanged();
    emit activeDeviceChanged();
}

void DualSenseClient::rescan() {
    if (m_simulationMode) {
        populateSimulatedDevice();
        return;
    }

    ExecResult res = runCli(QStringList() << "-l");
    QString output = res.stdOut + "\n" + res.stdErr;

    QRegularExpression devRegex(R"((?:/dev/)?([a-zA-Z0-9_\:\.]+)\s*\(([^)]+)\))");
    QRegularExpressionMatchIterator iter = devRegex.globalMatch(output);

    QList<QPair<QString, QString>> found; // id, type
    while (iter.hasNext()) {
        QRegularExpressionMatch match = iter.next();
        QString id = match.captured(1).trimmed();
        QString typeStr = match.captured(2).toLower();
        QString type = typeStr.contains("bluetooth") ? "Bluetooth" : (typeStr.contains("usb") ? "USB" : "Unknown");
        found.append(qMakePair(id, type));
    }

    if (found.isEmpty()) {
        // No hardware device found, fallback to simulation mode so GUI is immediately usable!
        m_simulationMode = true;
        emit simulationModeChanged();
        populateSimulatedDevice();
        emit toastRequested("Aucun DualSense physique détecté : Mode Simulation activé", "info");
        return;
    }

    // Hardware devices found!
    qDeleteAll(m_devices);
    m_devices.clear();

    for (const auto &p : found) {
        DualSenseDevice *dev = new DualSenseDevice(this);
        dev->setId(p.first);
        dev->setName("Sony DualSense (" + p.first + ")");
        dev->setConnectionType(p.second);
        updateBatteryForDevice(dev);
        updateFirmwareForDevice(dev);
        m_devices.append(dev);
    }

    m_activeIndex = 0;
    emit devicesChanged();
    emit activeIndexChanged();
    emit activeDeviceChanged();
    emit toastRequested(QString("%1 manette(s) DualSense connectée(s)").arg(m_devices.size()), "success");
}

void DualSenseClient::updateBatteryForDevice(DualSenseDevice *device) {
    if (!device) return;
    if (m_simulationMode) return;

    ExecResult res = runCli(QStringList() << "battery", device->id());
    if (res.success() && !res.stdOut.isEmpty()) {
        // Output format e.g. "80 discharging", "100 full", "45 charging"
        QStringList parts = res.stdOut.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
        if (!parts.isEmpty()) {
            bool ok = false;
            int pct = parts[0].toInt(&ok);
            if (ok) {
                device->setBatteryPercent(pct);
            }
            if (parts.size() > 1) {
                device->setBatteryStatus(parts[1].toLower());
            }
        }
    }
}

void DualSenseClient::updateFirmwareForDevice(DualSenseDevice *device) {
    if (!device) return;
    if (m_simulationMode) return;

    ExecResult res = runCli(QStringList() << "info", device->id());
    if (res.success() && !res.stdOut.isEmpty()) {
        // Look for Firmware version: and Build number:
        QRegularExpression fwRegex(R"(Firmware\s+version:\s*([0-9\.]+))", QRegularExpression::CaseInsensitiveOption);
        QRegularExpressionMatch fwMatch = fwRegex.match(res.stdOut);
        if (fwMatch.hasMatch()) {
            device->setFirmwareVersion(fwMatch.captured(1).trimmed());
        }

        QRegularExpression buildRegex(R"(Build\s+number:\s*([0-9a-fx]+))", QRegularExpression::CaseInsensitiveOption);
        QRegularExpressionMatch buildMatch = buildRegex.match(res.stdOut);
        if (buildMatch.hasMatch()) {
            device->setBuildNumber(buildMatch.captured(1).trimmed());
        }
    }
}

void DualSenseClient::onPollTimer() {
    if (m_simulationMode) return;

    DualSenseDevice *dev = activeDevice();
    if (dev) {
        updateBatteryForDevice(dev);
    }
}

bool DualSenseClient::setLightbar(int r, int g, int b, int brightness) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    r = qBound(0, r, 255);
    g = qBound(0, g, 255);
    b = qBound(0, b, 255);
    brightness = qBound(0, brightness, 255);

    dev->setLightbarColor(QColor(r, g, b));
    dev->setLightbarBrightness(brightness);
    dev->setLightbarEnabled(true);

    QStringList args;
    args << "lightbar" << QString::number(r) << QString::number(g) << QString::number(b) << QString::number(brightness);
    ExecResult res = runCli(args, dev->id());
    return res.success();
}

bool DualSenseClient::setLightbarEnabled(bool enabled) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    dev->setLightbarEnabled(enabled);
    QStringList args;
    args << "lightbar" << (enabled ? "on" : "off");
    ExecResult res = runCli(args, dev->id());
    return res.success();
}

bool DualSenseClient::setPlayerLeds(int leds, bool instant) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    leds = qBound(0, leds, 7);
    dev->setPlayerLeds(leds);

    QStringList args;
    args << "player-leds" << QString::number(leds);
    if (instant) {
        args << "instant";
    }
    ExecResult res = runCli(args, dev->id());
    return res.success();
}

bool DualSenseClient::setLedBrightness(int level) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    level = qBound(0, level, 2);
    dev->setLedBrightness(level);

    QStringList args;
    args << "led-brightness" << QString::number(level);
    ExecResult res = runCli(args, dev->id());
    return res.success();
}

bool DualSenseClient::setMicMuted(bool muted) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    dev->setMicMuted(muted);
    // When muted, set mic state 'off', and turn mic-led 'on' (Sony standard amber light)
    QStringList argsMic;
    argsMic << "microphone" << (muted ? "off" : "on");
    runCli(argsMic, dev->id());

    QStringList argsLed;
    argsLed << "microphone-led" << (muted ? "on" : "off");
    dev->setMicLedState(muted ? "on" : "off");
    runCli(argsLed, dev->id());

    emit toastRequested(muted ? "Microphone muet (LED orange allumée)" : "Microphone actif", muted ? "warning" : "success");
    return true;
}

bool DualSenseClient::setMicLed(const QString &state) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    QString s = state.toLower();
    if (s != "on" && s != "off" && s != "pulse") s = "off";
    dev->setMicLedState(s);

    QStringList args;
    args << "microphone-led" << s;
    ExecResult res = runCli(args, dev->id());
    return res.success();
}

bool DualSenseClient::setMicMode(const QString &mode) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    QString m = mode.toLower();
    if (m != "chat" && m != "asr" && m != "both") m = "chat";
    dev->setMicMode(m);

    QStringList args;
    args << "microphone-mode" << m;
    ExecResult res = runCli(args, dev->id());
    return res.success();
}

bool DualSenseClient::setSpeakerMode(const QString &mode) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    QString s = mode.toLower();
    if (s != "headphone" && s != "internal" && s != "both") s = "both";
    dev->setSpeakerMode(s);

    QStringList args;
    args << "speaker" << s;
    ExecResult res = runCli(args, dev->id());
    return res.success();
}

bool DualSenseClient::setVolume(int volume) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    volume = qBound(0, volume, 255);
    dev->setVolume(volume);

    QStringList args;
    args << "volume" << QString::number(volume);
    ExecResult res = runCli(args, dev->id());
    return res.success();
}

bool DualSenseClient::setAttenuation(int rumble, int trigger) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    rumble = qBound(0, rumble, 7);
    trigger = qBound(0, trigger, 7);
    dev->setRumbleAttenuation(rumble);
    dev->setTriggerAttenuation(trigger);

    QStringList args;
    args << "attenuation" << QString::number(rumble) << QString::number(trigger);
    ExecResult res = runCli(args, dev->id());
    return res.success();
}

bool DualSenseClient::setTriggerOff(const QString &target) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    QString tgt = target.toLower();
    if (tgt != "left" && tgt != "right" && tgt != "both") tgt = "both";

    if (tgt == "left" || tgt == "both") {
        dev->setLeftTriggerMode("off");
        dev->setLeftTriggerSummary("Standard / Aucun effet");
    }
    if (tgt == "right" || tgt == "both") {
        dev->setRightTriggerMode("off");
        dev->setRightTriggerSummary("Standard / Aucun effet");
    }

    QStringList args;
    args << "trigger" << tgt << "off";
    ExecResult res = runCli(args, dev->id());
    emit toastRequested("Gâchettes réinitialisées (Off)", "info");
    return res.success();
}

bool DualSenseClient::setTriggerFeedback(const QString &target, int position, int strength) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    QString tgt = target.toLower();
    if (tgt != "left" && tgt != "right" && tgt != "both") tgt = "both";

    position = qBound(0, position, 9);
    strength = qBound(1, strength, 8);

    QString summary = QString("Feedback (Position %1, Force %2)").arg(position).arg(strength);
    if (tgt == "left" || tgt == "both") {
        dev->setLeftTriggerMode("feedback");
        dev->setLeftTriggerSummary(summary);
    }
    if (tgt == "right" || tgt == "both") {
        dev->setRightTriggerMode("feedback");
        dev->setRightTriggerSummary(summary);
    }

    QStringList args;
    args << "trigger" << tgt << "feedback" << QString::number(position) << QString::number(strength);
    ExecResult res = runCli(args, dev->id());
    emit toastRequested(QString("Feedback appliqué (%1)").arg(tgt), "success");
    return res.success();
}

bool DualSenseClient::setTriggerWeapon(const QString &target, int start, int stop, int strength) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    QString tgt = target.toLower();
    if (tgt != "left" && tgt != "right" && tgt != "both") tgt = "both";

    int startVal = qBound(2, start, 7);
    int stopVal = qBound(startVal + 1, stop, 8);
    int strVal = qBound(1, strength, 8);

    QString summary = QString("Arme à feu (%1-%2, Dureté %3)").arg(startVal).arg(stopVal).arg(strVal);
    if (tgt == "left" || tgt == "both") {
        dev->setLeftTriggerMode("weapon");
        dev->setLeftTriggerSummary(summary);
    }
    if (tgt == "right" || tgt == "both") {
        dev->setRightTriggerMode("weapon");
        dev->setRightTriggerSummary(summary);
    }

    QStringList args;
    args << "trigger" << tgt << "weapon" << QString::number(startVal) << QString::number(stopVal) << QString::number(strVal);
    ExecResult res = runCli(args, dev->id());
    emit toastRequested(QString("Arme (Weapon) appliquée (%1)").arg(tgt), "success");
    return res.success();
}

bool DualSenseClient::setTriggerBow(const QString &target, int start, int stop, int strength, int snapforce) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    QString tgt = target.toLower();
    if (tgt != "left" && tgt != "right" && tgt != "both") tgt = "both";

    int startVal = qBound(0, start, 8);
    int stopVal = qBound(startVal + 1, stop, 8);
    int strVal = qBound(1, strength, 8);
    int snapVal = qBound(1, snapforce, 8);

    QString summary = QString("Arc élastique (%1-%2, Tension %3, Relâche %4)").arg(startVal).arg(stopVal).arg(strVal).arg(snapVal);
    if (tgt == "left" || tgt == "both") {
        dev->setLeftTriggerMode("bow");
        dev->setLeftTriggerSummary(summary);
    }
    if (tgt == "right" || tgt == "both") {
        dev->setRightTriggerMode("bow");
        dev->setRightTriggerSummary(summary);
    }

    QStringList args;
    args << "trigger" << tgt << "bow" << QString::number(startVal) << QString::number(stopVal) << QString::number(strVal) << QString::number(snapVal);
    ExecResult res = runCli(args, dev->id());
    emit toastRequested(QString("Arc (Bow) appliqué (%1)").arg(tgt), "success");
    return res.success();
}

bool DualSenseClient::setTriggerGalloping(const QString &target, int start, int stop, int foot1, int foot2, int freq) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    QString tgt = target.toLower();
    if (tgt != "left" && tgt != "right" && tgt != "both") tgt = "both";

    int startVal = qBound(0, start, 8);
    int stopVal = qBound(startVal + 1, stop, 9);
    int f1 = qBound(0, foot1, 8);
    int f2 = qBound(f1 + 1, foot2, 8);
    int f = qBound(1, freq, 20);

    QString summary = QString("Galop rythmique (Battements %1/%2 @ %3Hz)").arg(f1).arg(f2).arg(f);
    if (tgt == "left" || tgt == "both") {
        dev->setLeftTriggerMode("galloping");
        dev->setLeftTriggerSummary(summary);
    }
    if (tgt == "right" || tgt == "both") {
        dev->setRightTriggerMode("galloping");
        dev->setRightTriggerSummary(summary);
    }

    QStringList args;
    args << "trigger" << tgt << "galloping" << QString::number(startVal) << QString::number(stopVal) << QString::number(f1) << QString::number(f2) << QString::number(f);
    ExecResult res = runCli(args, dev->id());
    emit toastRequested(QString("Galop appliqué (%1)").arg(tgt), "success");
    return res.success();
}

bool DualSenseClient::setTriggerMachine(const QString &target, int start, int stop, int strA, int strB, int freq, int period) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    QString tgt = target.toLower();
    if (tgt != "left" && tgt != "right" && tgt != "both") tgt = "both";

    int startVal = qBound(1, start, 8);
    int stopVal = qBound(startVal + 1, stop, 8);
    int sA = qBound(0, strA, 7);
    int sB = qBound(0, strB, 7);
    int f = qBound(1, freq, 40);
    int p = qBound(1, period, 20);

    QString summary = QString("Mitrailleuse (%1-%2, Forces %3/%4, %5Hz)").arg(startVal).arg(stopVal).arg(sA).arg(sB).arg(f);
    if (tgt == "left" || tgt == "both") {
        dev->setLeftTriggerMode("machine");
        dev->setLeftTriggerSummary(summary);
    }
    if (tgt == "right" || tgt == "both") {
        dev->setRightTriggerMode("machine");
        dev->setRightTriggerSummary(summary);
    }

    QStringList args;
    args << "trigger" << tgt << "machine" << QString::number(startVal) << QString::number(stopVal) << QString::number(sA) << QString::number(sB) << QString::number(f) << QString::number(p);
    ExecResult res = runCli(args, dev->id());
    emit toastRequested(QString("Mitrailleuse (Machine) appliquée (%1)").arg(tgt), "success");
    return res.success();
}

bool DualSenseClient::setTriggerVibration(const QString &target, int pos, int amp, int freq) {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    QString tgt = target.toLower();
    if (tgt != "left" && tgt != "right" && tgt != "both") tgt = "both";

    int p = qBound(0, pos, 9);
    int a = qBound(1, amp, 8);
    int f = qBound(1, freq, 40);

    QString summary = QString("Vibration continue (Pos %1, Amp %2, %3Hz)").arg(p).arg(a).arg(f);
    if (tgt == "left" || tgt == "both") {
        dev->setLeftTriggerMode("vibration");
        dev->setLeftTriggerSummary(summary);
    }
    if (tgt == "right" || tgt == "both") {
        dev->setRightTriggerMode("vibration");
        dev->setRightTriggerSummary(summary);
    }

    QStringList args;
    args << "trigger" << tgt << "vibration" << QString::number(p) << QString::number(a) << QString::number(f);
    ExecResult res = runCli(args, dev->id());
    emit toastRequested(QString("Vibration de gâchette appliquée (%1)").arg(tgt), "success");
    return res.success();
}

bool DualSenseClient::powerOff() {
    DualSenseDevice *dev = activeDevice();
    if (!dev) return false;

    if (dev->connectionType() != "Bluetooth" && !m_simulationMode) {
        emit toastRequested("L'extinction matérielle n'est possible qu'en Bluetooth.", "warning");
        return false;
    }

    QStringList args;
    args << "power-off";
    ExecResult res = runCli(args, dev->id());
    emit toastRequested("Manette DualSense éteinte.", "info");

    if (m_simulationMode) {
        dev->setBatteryStatus("disconnected");
    } else {
        rescan();
    }
    return res.success();
}
