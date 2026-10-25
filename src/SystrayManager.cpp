#include "SystrayManager.h"
#include "core/DualSenseClient.h"
#include "core/DualSenseDevice.h"
#include "core/ProfileManager.h"
#include <QCoreApplication>
#include <QIcon>
#include <QAction>

SystrayManager::SystrayManager(DualSenseClient *client, ProfileManager *profileMgr, QObject *parent)
    : QObject(parent)
    , m_client(client)
    , m_profileMgr(profileMgr)
{
    m_trayIcon = new QSystemTrayIcon(this);
    m_trayIcon->setIcon(QIcon(":/icons/app-icon.svg"));

    m_menu = new QMenu();
    m_trayIcon->setContextMenu(m_menu);

    connect(m_trayIcon, &QSystemTrayIcon::activated, this, &SystrayManager::onTrayActivated);

    if (m_client) {
        connect(m_client, &DualSenseClient::activeDeviceChanged, this, &SystrayManager::updateTrayMenu);
        connect(m_client, &DualSenseClient::devicesChanged, this, &SystrayManager::updateTrayMenu);
    }
    if (m_profileMgr) {
        connect(m_profileMgr, &ProfileManager::profilesChanged, this, &SystrayManager::updateTrayMenu);
    }

    updateTrayMenu();
    m_trayIcon->show();
}

SystrayManager::~SystrayManager() {
    delete m_menu;
}

void SystrayManager::setTargetWindow(QWindow *window) {
    m_targetWindow = window;
}

void SystrayManager::onTrayActivated(QSystemTrayIcon::ActivationReason reason) {
    if (reason == QSystemTrayIcon::Trigger || reason == QSystemTrayIcon::DoubleClick) {
        if (m_targetWindow) {
            if (m_targetWindow->isVisible()) {
                m_targetWindow->hide();
            } else {
                m_targetWindow->show();
                m_targetWindow->raise();
                m_targetWindow->requestActivate();
            }
        }
    }
}

void SystrayManager::updateTooltip() {
    if (!m_client) return;
    DualSenseDevice *dev = m_client->activeDevice();
    if (dev) {
        m_trayIcon->setToolTip(QString("DualSense Expressive\n%1 (%2% - %3)")
                               .arg(dev->name())
                               .arg(dev->batteryPercent())
                               .arg(dev->batteryStatus()));
    } else {
        m_trayIcon->setToolTip("DualSense Expressive (Aucun contrôleur)");
    }
}

void SystrayManager::updateTrayMenu() {
    m_menu->clear();
    updateTooltip();

    DualSenseDevice *dev = m_client ? m_client->activeDevice() : nullptr;

    if (dev) {
        QAction *headerAct = m_menu->addAction(QString("🎮 %1 (%2%)").arg(dev->name()).arg(dev->batteryPercent()));
        headerAct->setEnabled(false);

        m_menu->addSeparator();

        // Toggle Mic Mute
        QAction *muteAct = m_menu->addAction(dev->micMuted() ? "🎙 Activer le microphone" : "🔇 Couper le microphone (Mute)");
        connect(muteAct, &QAction::triggered, this, [this, dev]() {
            m_client->setMicMuted(!dev->micMuted());
        });

        // Quick colors
        QMenu *colorMenu = m_menu->addMenu("🌈 Couleur Lightbar");
        auto addColor = [this, colorMenu](const QString &name, int r, int g, int b) {
            QAction *act = colorMenu->addAction(name);
            connect(act, &QAction::triggered, this, [this, r, g, b]() {
                m_client->setLightbar(r, g, b, 255);
            });
        };
        addColor("Bleu PS5", 0, 112, 209);
        addColor("Cyan Néon", 0, 240, 255);
        addColor("Rouge Cosmique", 255, 23, 68);
        addColor("Violet Galactique", 168, 85, 247);
        addColor("Vert Émeraude", 0, 230, 118);
        addColor("Blanc Pur", 255, 255, 255);

        // Power off (if BT)
        if (dev->connectionType() == "Bluetooth" || m_client->isSimulationMode()) {
            QAction *powerAct = m_menu->addAction("🔌 Éteindre la manette");
            connect(powerAct, &QAction::triggered, this, [this]() {
                m_client->powerOff();
            });
        }
    } else {
        QAction *noDevAct = m_menu->addAction("⚠️ Aucune manette connectée");
        noDevAct->setEnabled(false);
    }

    // Profiles submenu
    if (m_profileMgr) {
        QMenu *profMenu = m_menu->addMenu("⚡ Profils de Jeu");
        QVariantList profs = m_profileMgr->profiles();
        for (const auto &pVal : profs) {
            QString name = pVal.toMap()["name"].toString();
            QAction *pAct = profMenu->addAction(name);
            connect(pAct, &QAction::triggered, this, [this, name]() {
                m_profileMgr->applyProfile(name);
            });
        }
    }

    m_menu->addSeparator();

    // Show/Hide
    QAction *toggleAct = m_menu->addAction("Afficher / Masquer");
    connect(toggleAct, &QAction::triggered, this, [this]() {
        onTrayActivated(QSystemTrayIcon::Trigger);
    });

    QAction *quitAct = m_menu->addAction("Quitter");
    connect(quitAct, &QAction::triggered, qApp, &QCoreApplication::quit);
}
