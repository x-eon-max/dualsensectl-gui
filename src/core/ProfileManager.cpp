#include "ProfileManager.h"
#include "DualSenseClient.h"
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

ProfileManager::ProfileManager(DualSenseClient *client, QObject *parent)
    : QObject(parent)
    , m_client(client)
{
    loadProfiles();
    if (m_profiles.isEmpty()) {
        initDefaultProfiles();
    }
}

QString ProfileManager::configFilePath() const {
    QString configDir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/dualsense-expressive";
    QDir().mkpath(configDir);
    return configDir + "/profiles.json";
}

void ProfileManager::initDefaultProfiles() {
    m_profiles.clear();

    // 1. Competitive FPS
    {
        QVariantMap p;
        p["name"] = "Competitive FPS";
        p["description"] = "Hair-trigger break stop, attenuated rumble for aiming precision, mic muted";
        p["accentColor"] = "#FF1744";
        p["icon"] = "crosshair";
        p["lightbarR"] = 255; p["lightbarG"] = 23; p["lightbarB"] = 68; p["brightness"] = 255;
        p["micMuted"] = true;
        p["rumbleAtt"] = 5; p["triggerAtt"] = 2;
        p["triggerMode"] = "weapon";
        p["wpStart"] = 2; p["wpStop"] = 3; p["wpStr"] = 8;
        m_profiles.append(p);
    }

    // 2. Sim Racing
    {
        QVariantMap p;
        p["name"] = "Sim Racing Pro";
        p["description"] = "Firm brake pedal resistance (L2) and progressive throttle spring tension (R2)";
        p["accentColor"] = "#00F0FF";
        p["icon"] = "steering-wheel";
        p["lightbarR"] = 0; p["lightbarG"] = 240; p["lightbarB"] = 255; p["brightness"] = 255;
        p["micMuted"] = false;
        p["rumbleAtt"] = 0; p["triggerAtt"] = 0;
        p["triggerMode"] = "racing";
        m_profiles.append(p);
    }

    // 3. RPG Archer
    {
        QVariantMap p;
        p["name"] = "RPG Hunter & Bow";
        p["description"] = "Progressive bowstring draw tension with crisp snap force release";
        p["accentColor"] = "#00E676";
        p["icon"] = "bow";
        p["lightbarR"] = 0; p["lightbarG"] = 230; p["lightbarB"] = 118; p["brightness"] = 220;
        p["micMuted"] = false;
        p["rumbleAtt"] = 0; p["triggerAtt"] = 0;
        p["triggerMode"] = "bow";
        p["bowStart"] = 0; p["bowStop"] = 8; p["bowStr"] = 7; p["bowSnap"] = 8;
        m_profiles.append(p);
    }

    // 4. Heavy Recoil & Chaos
    {
        QVariantMap p;
        p["name"] = "Heavy Gunner (Machine)";
        p["description"] = "High-frequency machine recoil bursts and full tactile haptic feedback";
        p["accentColor"] = "#FF9100";
        p["icon"] = "flame";
        p["lightbarR"] = 255; p["lightbarG"] = 145; p["lightbarB"] = 0; p["brightness"] = 255;
        p["micMuted"] = false;
        p["rumbleAtt"] = 0; p["triggerAtt"] = 0;
        p["triggerMode"] = "machine";
        p["mStart"] = 1; p["mStop"] = 7; p["mStrA"] = 3; p["mStrB"] = 7; p["mFreq"] = 15; p["mPeriod"] = 2;
        m_profiles.append(p);
    }

    // 5. Cinematic Immersion
    {
        QVariantMap p;
        p["name"] = "Cinematic Immersion";
        p["description"] = "Cosmic violet ambient aura, rich haptics and smooth subtle triggers";
        p["accentColor"] = "#A855F7";
        p["icon"] = "sparkles";
        p["lightbarR"] = 168; p["lightbarG"] = 85; p["lightbarB"] = 247; p["brightness"] = 180;
        p["micMuted"] = false;
        p["rumbleAtt"] = 0; p["triggerAtt"] = 0;
        p["triggerMode"] = "feedback";
        p["fbPos"] = 4; p["fbStr"] = 3;
        m_profiles.append(p);
    }

    // 6. Stealth & Battery Saver
    {
        QVariantMap p;
        p["name"] = "Stealth Battery Saver";
        p["description"] = "LEDs turned off, mic muted, triggers disabled for maximum battery life";
        p["accentColor"] = "#64748B";
        p["icon"] = "battery";
        p["lightbarR"] = 0; p["lightbarG"] = 0; p["lightbarB"] = 0; p["brightness"] = 0;
        p["micMuted"] = true;
        p["rumbleAtt"] = 7; p["triggerAtt"] = 7;
        p["triggerMode"] = "off";
        m_profiles.append(p);
    }

    saveToFile();
    emit profilesChanged();
}

void ProfileManager::loadProfiles() {
    QFile file(configFilePath());
    if (!file.open(QIODevice::ReadOnly)) {
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    if (!doc.isArray()) {
        return;
    }

    m_profiles.clear();
    QJsonArray arr = doc.array();
    for (const auto &val : arr) {
        if (val.isObject()) {
            m_profiles.append(val.toObject().toVariantMap());
        }
    }
    emit profilesChanged();
}

void ProfileManager::saveToFile() {
    QJsonArray arr;
    for (const auto &p : m_profiles) {
        arr.append(QJsonObject::fromVariantMap(p.toMap()));
    }
    QJsonDocument doc(arr);

    QFile file(configFilePath());
    if (file.open(QIODevice::WriteOnly)) {
        file.write(doc.toJson(QJsonDocument::Indented));
    }
}

void ProfileManager::applyProfile(const QString &name) {
    if (!m_client) return;

    for (const auto &val : m_profiles) {
        QVariantMap p = val.toMap();
        if (p["name"].toString() == name) {
            m_activeProfileName = name;
            emit activeProfileNameChanged();

            // Lightbar
            int r = p["lightbarR"].toInt();
            int g = p["lightbarG"].toInt();
            int b = p["lightbarB"].toInt();
            int br = p.contains("brightness") ? p["brightness"].toInt() : 255;
            if (br == 0) {
                m_client->setLightbarEnabled(false);
            } else {
                m_client->setLightbar(r, g, b, br);
            }

            // Mic
            bool muted = p["micMuted"].toBool();
            m_client->setMicMuted(muted);

            // Attenuation
            int rumbleAtt = p["rumbleAtt"].toInt();
            int trigAtt = p["triggerAtt"].toInt();
            m_client->setAttenuation(rumbleAtt, trigAtt);

            // Trigger modes
            QString mode = p["triggerMode"].toString();
            if (mode == "off") {
                m_client->setTriggerOff("both");
            } else if (mode == "weapon") {
                m_client->setTriggerWeapon("both", p.value("wpStart", 2).toInt(), p.value("wpStop", 4).toInt(), p.value("wpStr", 8).toInt());
            } else if (mode == "bow") {
                m_client->setTriggerBow("both", p.value("bowStart", 0).toInt(), p.value("bowStop", 8).toInt(), p.value("bowStr", 6).toInt(), p.value("bowSnap", 8).toInt());
            } else if (mode == "machine") {
                m_client->setTriggerMachine("both", p.value("mStart", 1).toInt(), p.value("mStop", 7).toInt(), p.value("mStrA", 2).toInt(), p.value("mStrB", 7).toInt(), p.value("mFreq", 15).toInt(), p.value("mPeriod", 2).toInt());
            } else if (mode == "feedback") {
                m_client->setTriggerFeedback("both", p.value("fbPos", 3).toInt(), p.value("fbStr", 4).toInt());
            } else if (mode == "racing") {
                m_client->setTriggerFeedback("left", 2, 7); // Brake resistance
                m_client->setTriggerBow("right", 0, 8, 4, 6); // Throttle spring tension
            }

            emit m_client->toastRequested(QString("Profile applied: %1").arg(name), "success");
            return;
        }
    }
}

void ProfileManager::saveProfile(const QString &name, const QString &description, const QString &accentColor) {
    if (name.trimmed().isEmpty() || !m_client) return;

    DualSenseDevice *dev = m_client->activeDevice();
    if (!dev) return;

    QVariantMap p;
    p["name"] = name.trimmed();
    p["description"] = description.isEmpty() ? "Custom user profile" : description;
    p["accentColor"] = accentColor.isEmpty() ? "#7B5CFF" : accentColor;
    p["icon"] = "custom";

    QColor c = dev->lightbarColor();
    p["lightbarR"] = c.red();
    p["lightbarG"] = c.green();
    p["lightbarB"] = c.blue();
    p["brightness"] = dev->lightbarBrightness();

    p["micMuted"] = dev->micMuted();
    p["rumbleAtt"] = dev->rumbleAttenuation();
    p["triggerAtt"] = dev->triggerAttenuation();
    p["triggerMode"] = dev->leftTriggerMode();

    // Check if name already exists, update it, otherwise append
    bool updated = false;
    for (int i = 0; i < m_profiles.size(); ++i) {
        if (m_profiles[i].toMap()["name"].toString() == name) {
            m_profiles[i] = p;
            updated = true;
            break;
        }
    }
    if (!updated) {
        m_profiles.append(p);
    }

    saveToFile();
    emit profilesChanged();
    emit m_client->toastRequested(QString("Profile saved: %1").arg(name), "success");
}

void ProfileManager::deleteProfile(const QString &name) {
    for (int i = 0; i < m_profiles.size(); ++i) {
        if (m_profiles[i].toMap()["name"].toString() == name) {
            m_profiles.removeAt(i);
            saveToFile();
            emit profilesChanged();
            if (m_client) {
                emit m_client->toastRequested(QString("Profile deleted: %1").arg(name), "info");
            }
            return;
        }
    }
}
