#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include <QIcon>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QDebug>

#include "core/DualSenseDevice.h"
#include "core/DualSenseClient.h"
#include "core/ProfileManager.h"
#include "SystrayManager.h"

int main(int argc, char *argv[]) {
    // Enable High DPI scaling
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QApplication app(argc, argv);
    app.setApplicationName("dualsense-expressive");
    app.setApplicationDisplayName("DualSense Expressive");
    app.setOrganizationName("X-EON");
    app.setOrganizationDomain("github.com/x-eon-max");
    app.setWindowIcon(QIcon(":/icons/app-icon.svg"));

    // Set Material Quick style
    QQuickStyle::setStyle("Material");

    // Register custom C++ types to QML
    qmlRegisterType<DualSenseDevice>("io.github.x_eon_max.dualsense", 1, 0, "DualSenseDevice");
    qmlRegisterType<DualSenseClient>("io.github.x_eon_max.dualsense", 1, 0, "DualSenseClient");
    qmlRegisterType<ProfileManager>("io.github.x_eon_max.dualsense", 1, 0, "ProfileManager");

    DualSenseClient client;
    ProfileManager profileMgr(&client);

    // FreeDesktop / System Tray integration
    SystrayManager systray(&client, &profileMgr);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("dualsense", &client);
    engine.rootContext()->setContextProperty("profiles", &profileMgr);

    // Load Design System Tokens
    QQmlComponent tokensComp(&engine, QUrl(QStringLiteral("qrc:/ui/theme/ExpressiveTokens.qml")));
    QObject *tokensObj = tokensComp.create();
    if (tokensObj) {
        engine.rootContext()->setContextProperty("ExpressiveTokens", tokensObj);
    } else {
        qWarning() << "Erreur de création de ExpressiveTokens:" << tokensComp.errors();
    }

    const QUrl url(QStringLiteral("qrc:/ui/App.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [&systray, url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) {
                QCoreApplication::exit(-1);
                return;
            }
            QWindow *win = qobject_cast<QWindow*>(obj);
            if (win) {
                systray.setTargetWindow(win);
            }
        },
        Qt::QueuedConnection
    );

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Impossible de charger l'interface QML.";
        return -1;
    }

    return app.exec();
}
