import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "views"

ApplicationWindow {
    id: window
    visible: true
    width: 1180
    height: 820
    minimumWidth: 920
    minimumHeight: 640
    title: "DualSense Expressive"
    color: ExpressiveTokens.surface

    property int activeNav: 0 // 0=Dashboard, 1=Triggers, 2=Lighting, 3=Audio, 4=Profiles
    property var currentDevice: dualsense.activeDevice

    // Dynamic Top Ambient Lightbar Aura
    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.7
        height: 180
        radius: 90
        color: (currentDevice && currentDevice.lightbarEnabled) ? currentDevice.lightbarColor : ExpressiveTokens.primary
        opacity: (currentDevice && currentDevice.lightbarEnabled) ? ((currentDevice.lightbarBrightness / 255.0) * 0.16) : 0.05

        Behavior on color { ColorAnimation { duration: ExpressiveTokens.durationNormal } }
        Behavior on opacity { NumberAnimation { duration: ExpressiveTokens.durationNormal } }
    }

    // Top Header Bar
    header: Rectangle {
        height: 74
        color: ExpressiveTokens.surfaceContainerLowest
        border.color: ExpressiveTokens.outlineVariant
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            spacing: 16

            // App Brand Logo & Title
            RowLayout {
                spacing: 12

                Rectangle {
                    width: 42
                    height: 42
                    radius: 12
                    color: "transparent"

                    Image {
                        anchors.fill: parent
                        source: ":/icons/app-icon.svg"
                        fillMode: Image.PreserveAspectFit
                    }
                }

                ColumnLayout {
                    spacing: 0
                    RowLayout {
                        spacing: 6
                        Text {
                            text: "DualSense"
                            color: ExpressiveTokens.textSurface
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 18
                            font.weight: Font.Black
                        }
                        Text {
                            text: "Expressive"
                            color: ExpressiveTokens.primary
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 18
                            font.weight: Font.Black
                        }
                    }
                    Text {
                        text: "PlayStation 5 Controller Manager"
                        color: ExpressiveTokens.textSurfaceMuted
                        font.family: ExpressiveTokens.fontFamily
                        font.pixelSize: 11
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Simulation Mode Chip
            ExpressiveChip {
                text: dualsense.simulationMode ? "🧪 Mode Démo Actif" : "🎮 Mode Matériel"
                selected: dualsense.simulationMode
                activeColor: ExpressiveTokens.tertiary
                onClicked: dualsense.toggleSimulationMode()
            }

            // Rescan Device Button
            ExpressiveButton {
                text: "Actualiser"
                variant: "tonal"
                onClicked: dualsense.rescan()
            }
        }
    }

    // Main Content Layout
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Expressive Navigation Bar (Pill Tabs)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            color: ExpressiveTokens.surfaceContainerLowest
            border.color: ExpressiveTokens.outlineVariant
            border.width: 1

            RowLayout {
                anchors.centerIn: parent
                spacing: 12

                ExpressiveChip {
                    text: "📊 Tableau de Bord"
                    selected: window.activeNav === 0
                    onClicked: window.activeNav = 0
                }
                ExpressiveChip {
                    text: "🎯 Gâchettes Adaptatives"
                    selected: window.activeNav === 1
                    onClicked: window.activeNav = 1
                }
                ExpressiveChip {
                    text: "🌈 Éclairage RGB"
                    selected: window.activeNav === 2
                    onClicked: window.activeNav = 2
                }
                ExpressiveChip {
                    text: "🎙 Audio & Micro"
                    selected: window.activeNav === 3
                    onClicked: window.activeNav = 3
                }
                ExpressiveChip {
                    text: "⚡ Profils de Jeu"
                    selected: window.activeNav === 4
                    onClicked: window.activeNav = 4
                }
            }
        }

        // Active View Container
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StackLayout {
                anchors.fill: parent
                anchors.margins: 24
                currentIndex: window.activeNav

                DashboardView {}
                TriggersView {}
                LightingView {}
                AudioView {}
                ProfilesView {}
            }
        }
    }

    // Floating Action Button (FAB)
    ExpressiveFAB {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28
        onQuickMuteRequested: {
            if (currentDevice) {
                dualsense.setMicMuted(!currentDevice.micMuted)
            }
        }
        onPowerOffRequested: {
            dualsense.powerOff()
        }
        onRescanRequested: {
            dualsense.rescan()
        }
    }

    // Toast Notification Banner
    NotificationToast {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
    }

    Connections {
        target: dualsense
        function onToastRequested(message, type) {
            toast.show(message, type)
        }
    }
}
