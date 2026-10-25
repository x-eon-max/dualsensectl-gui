#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>

class DualSenseClient;

class ProfileManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(QVariantList profiles READ profiles NOTIFY profilesChanged)
    Q_PROPERTY(QString activeProfileName READ activeProfileName NOTIFY activeProfileNameChanged)

public:
    explicit ProfileManager(DualSenseClient *client, QObject *parent = nullptr);

    QVariantList profiles() const { return m_profiles; }
    QString activeProfileName() const { return m_activeProfileName; }

    Q_INVOKABLE void applyProfile(const QString &name);
    Q_INVOKABLE void saveProfile(const QString &name, const QString &description, const QString &accentColor);
    Q_INVOKABLE void deleteProfile(const QString &name);

signals:
    void profilesChanged();
    void activeProfileNameChanged();

private:
    void initDefaultProfiles();
    void loadProfiles();
    void saveToFile();
    QString configFilePath() const;

    DualSenseClient *m_client{nullptr};
    QVariantList m_profiles;
    QString m_activeProfileName{"Default DualSense"};
};
