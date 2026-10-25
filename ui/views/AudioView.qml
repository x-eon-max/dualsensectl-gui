import QtQuick
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property var device: dualsense.activeDevice
    property bool micMuted: device ? device.micMuted : false
    property string micLedState: device ? device.micLedState : "off"
    property string micMode: device ? device.micMode : "chat"
    property string speakerMode: device ? device.speakerMode : "both"
    property int volume: device ? device.volume : 200
    property int rumbleAtt: device ? device.rumbleAttenuation : 0
    property int triggerAtt: device ? device.triggerAttenuation : 0

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

            // Top Header Card
            ExpressiveCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                glowColor: root.micMuted ? ExpressiveTokens.amberWarning : ExpressiveTokens.successColor

                RowLayout {
                    anchors.fill: parent
                    spacing: 20

                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: "🎙 AUDIO, MICROPHONE & HAPTIQUE"
                            color: ExpressiveTokens.textSurface
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 18
                            font.weight: Font.Black
                        }
                        Text {
                            text: "Gestion du micro matériel, routage haut-parleur/casque et atténuation du retour haptique"
                            color: ExpressiveTokens.textSurfaceMuted
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 13
                        }
                    }

                    Item { Layout.fillWidth: true }

                    StatusBadge {
                        text: root.micMuted ? "MICROPHONE COUPÉ" : "MICROPHONE ACTIF"
                        dotColor: root.micMuted ? ExpressiveTokens.amberWarning : ExpressiveTokens.successColor
                    }
                }
            }

            // Big Microphone Toggle Card
            ExpressiveCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 130
                cardColor: root.micMuted ? Qt.rgba(255/255, 140/255, 0/255, 0.12) : ExpressiveTokens.surfaceContainer
                borderColor: root.micMuted ? ExpressiveTokens.amberWarning : ExpressiveTokens.outlineVariant

                RowLayout {
                    anchors.fill: parent
                    spacing: 24

                    Rectangle {
                        width: 60
                        height: 60
                        radius: 30
                        color: root.micMuted ? ExpressiveTokens.amberWarning : ExpressiveTokens.successColor
                        Text {
                            anchors.centerIn: parent
                            text: root.micMuted ? "🔇" : "🎙"
                            font.pixelSize: 28
                        }
                    }

                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: root.micMuted ? "Microphone Matériel Désactivé" : "Microphone Matériel Actif"
                            color: ExpressiveTokens.textSurface
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 16
                            font.weight: Font.Bold
                        }
                        Text {
                            text: root.micMuted ? "La LED orange de la manette est allumée. Aucun flux audio n'est capté." : "Le microphone est ouvert pour le chat vocal et la reconnaissance vocale."
                            color: ExpressiveTokens.textSurfaceMuted
                            font.pixelSize: 13
                        }
                    }

                    Item { Layout.fillWidth: true }

                    ExpressiveButton {
                        text: root.micMuted ? "Activer le Micro" : "Couper le Micro (Mute)"
                        variant: root.micMuted ? "primary" : "danger"
                        accentColor: root.micMuted ? ExpressiveTokens.successColor : ExpressiveTokens.amberWarning
                        onClicked: dualsense.setMicMuted(!root.micMuted)
                    }
                }
            }

            // Microphone LED & Routing Options
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                ExpressiveCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    cardColor: ExpressiveTokens.surfaceContainer

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Text { text: "COMPORTEMENT DE LA LED DU MICRO"; color: ExpressiveTokens.textSurfaceMuted; font.pixelSize: 12; font.weight: Font.Bold }

                        RowLayout {
                            spacing: 8
                            ExpressiveChip { text: "Éteinte (Off)"; selected: root.micLedState === "off"; onClicked: { root.micLedState = "off"; dualsense.setMicLed("off") } }
                            ExpressiveChip { text: "Fixe (On)"; selected: root.micLedState === "on"; onClicked: { root.micLedState = "on"; dualsense.setMicLed("on") } }
                            ExpressiveChip { text: "Pulsation (Pulse)"; selected: root.micLedState === "pulse"; onClicked: { root.micLedState = "pulse"; dualsense.setMicLed("pulse") } }
                        }

                        Text { text: "USAGE DU MICROPHONE"; color: ExpressiveTokens.textSurfaceMuted; font.pixelSize: 12; font.weight: Font.Bold }

                        RowLayout {
                            spacing: 8
                            ExpressiveChip { text: "Chat Vocal (Chat)"; selected: root.micMode === "chat"; onClicked: { root.micMode = "chat"; dualsense.setMicMode("chat") } }
                            ExpressiveChip { text: "Reconnaissance (ASR)"; selected: root.micMode === "asr"; onClicked: { root.micMode = "asr"; dualsense.setMicMode("asr") } }
                            ExpressiveChip { text: "Les Deux (Both)"; selected: root.micMode === "both"; onClicked: { root.micMode = "both"; dualsense.setMicMode("both") } }
                        }
                    }
                }

                ExpressiveCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    cardColor: ExpressiveTokens.surfaceContainer

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        Text { text: "ROUTAGE DU HAUT-PARLEUR"; color: ExpressiveTokens.textSurfaceMuted; font.pixelSize: 12; font.weight: Font.Bold }

                        RowLayout {
                            spacing: 8
                            ExpressiveChip { text: "Casque Audio (Headphone)"; selected: root.speakerMode === "headphone"; onClicked: { root.speakerMode = "headphone"; dualsense.setSpeakerMode("headphone") } }
                            ExpressiveChip { text: "Haut-Parleur Interne"; selected: root.speakerMode === "internal"; onClicked: { root.speakerMode = "internal"; dualsense.setSpeakerMode("internal") } }
                            ExpressiveChip { text: "Les Deux (Both)"; selected: root.speakerMode === "both"; onClicked: { root.speakerMode = "both"; dualsense.setSpeakerMode("both") } }
                        }

                        Text { text: "VOLUME PRINCIPAL"; color: ExpressiveTokens.textSurfaceMuted; font.pixelSize: 12; font.weight: Font.Bold }

                        ExpressiveSlider {
                            Layout.fillWidth: true
                            from: 0; to: 255
                            value: root.volume
                            unit: " / 255"
                            onMoved: function(v) {
                                root.volume = Math.round(v)
                                dualsense.setVolume(root.volume)
                            }
                        }
                    }
                }
            }

            // Haptics & Vibration Attenuation Card
            ExpressiveCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                cardColor: ExpressiveTokens.surfaceContainer

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 16

                    Text {
                        text: "📳 ATTÉNUATION DU RETOUR HAPTIQUE (RUMBLE & GÂCHETTES)"
                        color: ExpressiveTokens.textSurfaceMuted
                        font.family: ExpressiveTokens.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 24

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            RowLayout {
                                Text { text: "Atténuation Moteurs Haptiques (0 = 100%, 7 = 12.5%)"; color: ExpressiveTokens.textSurface; font.pixelSize: 12 }
                                Item { Layout.fillWidth: true }
                                Text { text: "Niveau " + root.rumbleAtt; color: ExpressiveTokens.primary; font.weight: Font.Bold; font.pixelSize: 12 }
                            }
                            ExpressiveSlider {
                                Layout.fillWidth: true
                                from: 0; to: 7
                                value: root.rumbleAtt
                                onMoved: function(v) {
                                    root.rumbleAtt = Math.round(v)
                                    dualsense.setAttenuation(root.rumbleAtt, root.triggerAtt)
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            RowLayout {
                                Text { text: "Atténuation Vibrations Gâchettes (0 = Max, 7 = Min)"; color: ExpressiveTokens.textSurface; font.pixelSize: 12 }
                                Item { Layout.fillWidth: true }
                                Text { text: "Niveau " + root.triggerAtt; color: ExpressiveTokens.primary; font.weight: Font.Bold; font.pixelSize: 12 }
                            }
                            ExpressiveSlider {
                                Layout.fillWidth: true
                                from: 0; to: 7
                                value: root.triggerAtt
                                onMoved: function(v) {
                                    root.triggerAtt = Math.round(v)
                                    dualsense.setAttenuation(root.rumbleAtt, root.triggerAtt)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
