#pragma once

#include <QObject>
#include <QSystemTrayIcon>
#include <QMenu>
#include <QWindow>

class DualSenseClient;
class ProfileManager;

class SystrayManager : public QObject {
    Q_OBJECT

public:
    explicit SystrayManager(DualSenseClient *client, ProfileManager *profileMgr, QObject *parent = nullptr);
    ~SystrayManager();

    void setTargetWindow(QWindow *window);

private slots:
    void onTrayActivated(QSystemTrayIcon::ActivationReason reason);
    void updateTrayMenu();
    void updateTooltip();

private:
    DualSenseClient *m_client{nullptr};
    ProfileManager *m_profileMgr{nullptr};
    QSystemTrayIcon *m_trayIcon{nullptr};
    QMenu *m_menu{nullptr};
    QWindow *m_targetWindow{nullptr};
};
