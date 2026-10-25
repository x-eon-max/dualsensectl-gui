import QtQuick
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property var device: dualsense.activeDevice

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentCol.implicitHeight + 40
        clip: true

        ColumnLayout {
            id: contentCol
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width - 48, 1080)
            spacing: 24

            // Top Hero Card: Interactive DualSense Controller
            ExpressiveCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 340
                glowColor: device ? device.lightbarColor : ExpressiveTokens.primary

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    // Card Header with Status Badges
                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            spacing: 2
                            Text {
                                text: device ? device.name : "DualSense Wireless Controller"
                                color: ExpressiveTokens.textSurface
                                font.family: ExpressiveTokens.fontFamily
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }
                            Text {
                                text: device ? (device.id + " • " + (device.isCharging ? "En charge..." : device.batteryStatus)) : "Non connecté"
                                color: ExpressiveTokens.textSurfaceMuted
                                font.family: ExpressiveTokens.fontFamily
                                font.pixelSize: 12
                            }
                        }

                        Item { Layout.fillWidth: true }

                        StatusBadge {
                            text: device ? (device.batteryPercent + "%") : "--"
                            dotColor: {
                                if (!device) return ExpressiveTokens.textSurfaceMuted
                                if (device.batteryPercent > 40) return ExpressiveTokens.successColor
                                if (device.batteryPercent > 15) return ExpressiveTokens.warningColor
                                return ExpressiveTokens.errorColor
                            }
                            pulsing: device ? device.isCharging : false
                        }

                        StatusBadge {
                            text: device ? device.connectionType : "Déconnecté"
                            dotColor: (device && device.connectionType === "Bluetooth") ? ExpressiveTokens.primary : ExpressiveTokens.secondary
                        }
                    }

                    // Interactive DualSense Graphic
                    InteractiveDualSense {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        lightbarColor: device ? device.lightbarColor : "#388BFF"
                        lightbarBrightness: device ? device.lightbarBrightness : 255
                        lightbarEnabled: device ? device.lightbarEnabled : true
                        playerLeds: device ? device.playerLeds : 1
                        micMuted: device ? device.micMuted : false
                    }
                }
            }

            // Two-Column Grid for Metrics & Quick Actions
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                // Card 1: Battery & Power
                ExpressiveCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 240
                    cardColor: ExpressiveTokens.surfaceContainer

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 14

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "⚡ ÉNERGIE & BATTERIE"
                                color: ExpressiveTokens.textSurfaceMuted
                                font.family: ExpressiveTokens.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.Bold
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: device ? (device.batteryPercent + "%") : "0%"
                                color: ExpressiveTokens.textSurface
                                font.family: ExpressiveTokens.fontMono
                                font.pixelSize: 18
                                font.weight: Font.Black
                            }
                        }

                        // Battery gauge bar
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            radius: 10
                            color: ExpressiveTokens.surfaceContainerHighest
                            clip: true

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: parent.width * ((device ? device.batteryPercent : 0) / 100.0)
                                radius: 10
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: ExpressiveTokens.primary }
                                    GradientStop { position: 1.0; color: (device && device.batteryPercent <= 20) ? ExpressiveTokens.errorColor : ExpressiveTokens.successColor }
                                }
                                Behavior on width { NumberAnimation { duration: ExpressiveTokens.durationNormal; easing.type: Easing.OutCubic } }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            ColumnLayout {
                                spacing: 2
                                Text { text: "État d'alimentation"; color: ExpressiveTokens.textSurfaceMuted; font.pixelSize: 11 }
                                Text { text: device ? device.batteryStatus.toUpperCase() : "DISCHARGING"; color: ExpressiveTokens.textSurface; font.weight: Font.Bold; font.pixelSize: 13 }
                            }
                            Item { Layout.fillWidth: true }
                            ColumnLayout {
                                spacing: 2
                                Text { text: "Interface système"; color: ExpressiveTokens.textSurfaceMuted; font.pixelSize: 11 }
                                Text { text: device ? ("/dev/" + device.id) : "/dev/hidraw0"; color: ExpressiveTokens.primary; font.family: ExpressiveTokens.fontMono; font.weight: Font.Bold; font.pixelSize: 12 }
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // BT Power off button
                        ExpressiveButton {
                            Layout.fillWidth: true
                            text: "Éteindre la manette (Bluetooth)"
                            variant: "outlined"
                            accentColor: ExpressiveTokens.errorColor
                            enabled: device ? (device.connectionType === "Bluetooth" || dualsense.simulationMode) : false
                            onClicked: dualsense.powerOff()
                        }
                    }
                }

                // Card 2: Quick Hardware Controls
                ExpressiveCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 240
                    cardColor: ExpressiveTokens.surfaceContainer

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 14

                        Text {
                            text: "🎛 CONTRÔLES RAPIDES"
                            color: ExpressiveTokens.textSurfaceMuted
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        // Big Mic Mute Toggle
                        ExpressiveButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 46
                            text: (device && device.micMuted) ? "🔇 MICROPHONE COUPÉ (MUTE)" : "🎙 MICROPHONE ACTIF"
                            variant: (device && device.micMuted) ? "danger" : "secondary"
                            accentColor: (device && device.micMuted) ? ExpressiveTokens.amberWarning : ExpressiveTokens.successColor
                            onClicked: {
                                if (device) dualsense.setMicMuted(!device.micMuted)
                            }
                        }

                        // Quick volume slider
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Text { text: "Volume"; color: ExpressiveTokens.textSurface; font.pixelSize: 12; font.weight: Font.Medium }
                            ExpressiveSlider {
                                Layout.fillWidth: true
                                from: 0; to: 255
                                value: device ? device.volume : 200
                                unit: " / 255"
                                onMoved: function(v) { dualsense.setVolume(Math.round(v)) }
                            }
                        }

                        // Lightbar quick toggle
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Bandeau lumineux (Lightbar)"; color: ExpressiveTokens.textSurface; font.pixelSize: 12; font.weight: Font.Medium }
                            Item { Layout.fillWidth: true }
                            ExpressiveSwitch {
                                checked: device ? device.lightbarEnabled : true
                                onToggled: function(st) { dualsense.setLightbarEnabled(st) }
                            }
                        }
                    }
                }
            }

            // Firmware & Hardware Diagnostics Card
            ExpressiveCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                cardColor: ExpressiveTokens.surfaceContainerLow

                RowLayout {
                    anchors.fill: parent
                    spacing: 24

                    ColumnLayout {
                        spacing: 4
                        Text { text: "FIRMWARE KERNEL"; color: ExpressiveTokens.textSurfaceMuted; font.pixelSize: 11; font.weight: Font.Bold }
                        Text { text: device ? ("v" + device.firmwareVersion) : "v0307.0014"; color: ExpressiveTokens.textSurface; font.family: ExpressiveTokens.fontMono; font.pixelSize: 14; font.weight: Font.Bold }
                    }

                    Rectangle { width: 1; Layout.fillHeight: true; color: ExpressiveTokens.outlineVariant }

                    ColumnLayout {
                        spacing: 4
                        Text { text: "BUILD NUMBER"; color: ExpressiveTokens.textSurfaceMuted; font.pixelSize: 11; font.weight: Font.Bold }
                        Text { text: device ? device.buildNumber : "0x00000000"; color: ExpressiveTokens.textSurface; font.family: ExpressiveTokens.fontMono; font.pixelSize: 14; font.weight: Font.Bold }
                    }

                    Rectangle { width: 1; Layout.fillHeight: true; color: ExpressiveTokens.outlineVariant }

                    ColumnLayout {
                        spacing: 4
                        Text { text: "GÂCHETTE GAUCHE (L2)"; color: ExpressiveTokens.textSurfaceMuted; font.pixelSize: 11; font.weight: Font.Bold }
                        Text { text: device ? device.leftTriggerSummary : "Standard"; color: ExpressiveTokens.primary; font.pixelSize: 13; font.weight: Font.Medium }
                    }

                    Rectangle { width: 1; Layout.fillHeight: true; color: ExpressiveTokens.outlineVariant }

                    ColumnLayout {
                        spacing: 4
                        Text { text: "GÂCHETTE DROITE (R2)"; color: ExpressiveTokens.textSurfaceMuted; font.pixelSize: 11; font.weight: Font.Bold }
                        Text { text: device ? device.rightTriggerSummary : "Standard"; color: ExpressiveTokens.primary; font.pixelSize: 13; font.weight: Font.Medium }
                    }
                }
            }
        }
    }
}
