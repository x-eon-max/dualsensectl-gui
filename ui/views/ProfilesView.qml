import QtQuick
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property var profileList: profiles.profiles
    property string activeProfile: profiles.activeProfileName

    property bool showSaveDialog: false
    property string newProfileName: ""
    property string newProfileDesc: ""

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
                glowColor: ExpressiveTokens.primary

                RowLayout {
                    anchors.fill: parent
                    spacing: 20

                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: "⚡ GESTIONNAIRE DE PROFILS DE JEU"
                            color: ExpressiveTokens.textSurface
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 18
                            font.weight: Font.Black
                        }
                        Text {
                            text: "Basculez instantanément entre vos configurations personnalisées selon le jeu lancé"
                            color: ExpressiveTokens.textSurfaceMuted
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 13
                        }
                    }

                    Item { Layout.fillWidth: true }

                    ExpressiveButton {
                        text: "+ Enregistrer l'état actuel"
                        variant: "primary"
                        onClicked: root.showSaveDialog = true
                    }
                }
            }

            // Save Dialog Card
            ExpressiveCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                visible: root.showSaveDialog
                cardColor: ExpressiveTokens.surfaceContainerHigh
                borderColor: ExpressiveTokens.primary

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    Text {
                        text: "💾 ENREGISTRER UN NOUVEAU PROFIL"
                        color: ExpressiveTokens.primary
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            radius: 20
                            color: ExpressiveTokens.surfaceContainerLowest
                            border.color: ExpressiveTokens.outlineVariant

                            TextInput {
                                id: inputName
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                verticalAlignment: TextInput.AlignVCenter
                                color: ExpressiveTokens.textSurface
                                font.family: ExpressiveTokens.fontFamily
                                font.pixelSize: 13
                                clip: true
                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "Nom du profil (ex: Cyberpunk 2077, Elden Ring...)"
                                    color: ExpressiveTokens.textSurfaceMuted
                                    visible: !inputName.text && !inputName.activeFocus
                                    font.pixelSize: 13
                                }
                            }
                        }

                        ExpressiveButton {
                            text: "Sauvegarder"
                            variant: "primary"
                            onClicked: {
                                if (inputName.text.trim() !== "") {
                                    profiles.saveProfile(inputName.text.trim(), "Profil utilisateur personnalisé", "#7B5CFF")
                                    inputName.text = ""
                                    root.showSaveDialog = false
                                }
                            }
                        }

                        ExpressiveButton {
                            text: "Annuler"
                            variant: "outlined"
                            onClicked: root.showSaveDialog = false
                        }
                    }
                }
            }

            // Profiles Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 18
                columnSpacing: 18

                Repeater {
                    model: root.profileList

                    delegate: ExpressiveCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        cardColor: (root.activeProfile === modelData.name) ? ExpressiveTokens.surfaceContainerHigh : ExpressiveTokens.surfaceContainer
                        borderColor: (root.activeProfile === modelData.name) ? modelData.accentColor : ExpressiveTokens.outlineVariant
                        glowColor: (root.activeProfile === modelData.name) ? modelData.accentColor : "transparent"

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                Rectangle {
                                    width: 14
                                    height: 14
                                    radius: 7
                                    color: modelData.accentColor
                                }

                                Text {
                                    text: modelData.name
                                    color: ExpressiveTokens.textSurface
                                    font.family: ExpressiveTokens.fontFamily
                                    font.pixelSize: 16
                                    font.weight: Font.Bold
                                }

                                Item { Layout.fillWidth: true }

                                StatusBadge {
                                    visible: root.activeProfile === modelData.name
                                    text: "ACTIF"
                                    dotColor: modelData.accentColor
                                }
                            }

                            Text {
                                text: modelData.description
                                color: ExpressiveTokens.textSurfaceMuted
                                font.family: ExpressiveTokens.fontFamily
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                ExpressiveButton {
                                    text: (root.activeProfile === modelData.name) ? "✓ Appliqué" : "⚡ Activer ce profil"
                                    variant: (root.activeProfile === modelData.name) ? "tonal" : "primary"
                                    accentColor: modelData.accentColor
                                    onClicked: profiles.applyProfile(modelData.name)
                                }

                                Item { Layout.fillWidth: true }

                                ExpressiveButton {
                                    visible: modelData.icon === "custom"
                                    text: "Supprimer"
                                    variant: "danger"
                                    onClicked: profiles.deleteProfile(modelData.name)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
