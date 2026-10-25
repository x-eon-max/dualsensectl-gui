import QtQuick
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property var device: dualsense.activeDevice
    property string targetTrigger: "both" // "left", "right", "both"
    property string activeMode: "weapon" // "off", "feedback", "weapon", "bow", "machine", "galloping", "vibration"

    // Parameters
    property int fbPos: 2
    property int fbStr: 6

    property int wpStart: 2
    property int wpStop: 5
    property int wpStr: 7

    property int bowStart: 0
    property int bowStop: 7
    property int bowStr: 6
    property int bowSnap: 8

    property int mStart: 1
    property int mStop: 7
    property int mStrA: 2
    property int mStrB: 7
    property int mFreq: 12
    property int mPeriod: 2

    property int galStart: 0
    property int galStop: 8
    property int galF1: 2
    property int galF2: 5
    property int galFreq: 4

    property int vibPos: 3
    property int vibAmp: 6
    property int vibFreq: 24

    function applyCurrentMode() {
        switch (activeMode) {
            case "off":
                dualsense.setTriggerOff(targetTrigger)
                break
            case "feedback":
                dualsense.setTriggerFeedback(targetTrigger, fbPos, fbStr)
                break
            case "weapon":
                dualsense.setTriggerWeapon(targetTrigger, wpStart, wpStop, wpStr)
                break
            case "bow":
                dualsense.setTriggerBow(targetTrigger, bowStart, bowStop, bowStr, bowSnap)
                break
            case "machine":
                dualsense.setTriggerMachine(targetTrigger, mStart, mStop, mStrA, mStrB, mFreq, mPeriod)
                break
            case "galloping":
                dualsense.setTriggerGalloping(targetTrigger, galStart, galStop, galF1, galF2, galFreq)
                break
            case "vibration":
                dualsense.setTriggerVibration(targetTrigger, vibPos, vibAmp, vibFreq)
                break
        }
    }

    function applyPreset(presetId) {
        switch (presetId) {
            case "handgun":
                activeMode = "weapon"
                wpStart = 2; wpStop = 4; wpStr = 7
                break
            case "shotgun":
                activeMode = "weapon"
                wpStart = 4; wpStop = 6; wpStr = 8
                break
            case "sniper":
                activeMode = "feedback"
                fbPos = 3; fbStr = 7
                break
            case "bow":
                activeMode = "bow"
                bowStart = 0; bowStop = 8; bowStr = 6; bowSnap = 8
                break
            case "machine":
                activeMode = "machine"
                mStart = 1; mStop = 7; mStrA = 2; mStrB = 7; mFreq = 16; mPeriod = 2
                break
            case "gallop":
                activeMode = "galloping"
                galStart = 0; galStop = 8; galF1 = 2; galF2 = 5; galFreq = 4
                break
            case "vibration":
                activeMode = "vibration"
                vibPos = 2; vibAmp = 6; vibFreq = 26
                break
            case "off":
                activeMode = "off"
                break
        }
        applyCurrentMode()
    }

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

            // Top Studio Header Card
            ExpressiveCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                cardColor: ExpressiveTokens.surfaceContainer

                RowLayout {
                    anchors.fill: parent
                    spacing: 20

                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: "🎯 ADAPTIVE TRIGGERS STUDIO"
                            color: ExpressiveTokens.textSurface
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 18
                            font.weight: Font.Black
                        }
                        Text {
                            text: "Contrôle micrométrique des servomoteurs L2 et R2 (Résistance, Cran de tir, Tension d'arc, Recul)"
                            color: ExpressiveTokens.textSurfaceMuted
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 13
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Target Trigger Selector
                    RowLayout {
                        spacing: 8
                        Text { text: "Cible :"; color: ExpressiveTokens.textSurface; font.weight: Font.Bold; font.pixelSize: 13 }
                        ExpressiveChip {
                            text: "Gauche (L2)"
                            selected: root.targetTrigger === "left"
                            onClicked: root.targetTrigger = "left"
                        }
                        ExpressiveChip {
                            text: "Droite (R2)"
                            selected: root.targetTrigger === "right"
                            onClicked: root.targetTrigger = "right"
                        }
                        ExpressiveChip {
                            text: "Les Deux (L2 + R2)"
                            selected: root.targetTrigger === "both"
                            onClicked: root.targetTrigger = "both"
                        }
                    }
                }
            }

            // Quick Presets Row
            ExpressiveCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 84
                cardColor: ExpressiveTokens.surfaceContainerLow

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Text {
                        text: "⚡ PRÉRÉGLAGES :"
                        color: ExpressiveTokens.textSurfaceMuted
                        font.family: ExpressiveTokens.fontFamily
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: presetRow.implicitWidth
                        clip: true

                        RowLayout {
                            id: presetRow
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            ExpressiveChip { text: "🔫 Pistolet Semi-Auto"; onClicked: applyPreset("handgun") }
                            ExpressiveChip { text: "💥 Fusil à Pompe Lourd"; onClicked: applyPreset("shotgun") }
                            ExpressiveChip { text: "🎯 Résistance Sniper"; onClicked: applyPreset("sniper") }
                            ExpressiveChip { text: "🏹 Arc Élastique"; onClicked: applyPreset("bow") }
                            ExpressiveChip { text: "🔥 Mitrailleuse Lourde"; onClicked: applyPreset("machine") }
                            ExpressiveChip { text: "🐎 Galop de Cheval"; onClicked: applyPreset("gallop") }
                            ExpressiveChip { text: "⚡ Bourdonnement Moteur"; onClicked: applyPreset("vibration") }
                            ExpressiveChip { text: "⚪ Aucun Effet (Off)"; onClicked: applyPreset("off") }
                        }
                    }
                }
            }

            // Mode Selector Bar
            ExpressiveCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 76
                cardColor: ExpressiveTokens.surfaceContainer

                RowLayout {
                    anchors.fill: parent
                    spacing: 8

                    Text {
                        text: "Mode : "
                        color: ExpressiveTokens.textSurfaceMuted
                        font.family: ExpressiveTokens.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    ExpressiveChip { text: "Désactivé (Off)"; selected: root.activeMode === "off"; onClicked: root.activeMode = "off" }
                    ExpressiveChip { text: "Résistance (Feedback)"; selected: root.activeMode === "feedback"; onClicked: root.activeMode = "feedback" }
                    ExpressiveChip { text: "Arme à Feu (Weapon)"; selected: root.activeMode === "weapon"; onClicked: root.activeMode = "weapon" }
                    ExpressiveChip { text: "Corde d'Arc (Bow)"; selected: root.activeMode === "bow"; onClicked: root.activeMode = "bow" }
                    ExpressiveChip { text: "Mitrailleuse (Machine)"; selected: root.activeMode === "machine"; onClicked: root.activeMode = "machine" }
                    ExpressiveChip { text: "Galop (Galloping)"; selected: root.activeMode === "galloping"; onClicked: root.activeMode = "galloping" }
                    ExpressiveChip { text: "Vibration"; selected: root.activeMode === "vibration"; onClicked: root.activeMode = "vibration" }
                }
            }

            // Main Editor Section (Parameters + Real-Time Waveform Graph)
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                // Sliders Configuration Panel
                ExpressiveCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 330
                    cardColor: ExpressiveTokens.surfaceContainer

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 14

                        Text {
                            text: "PARAMÈTRES DU MODE " + root.activeMode.toUpperCase()
                            color: ExpressiveTokens.primary
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }

                        // Mode Off
                        ColumnLayout {
                            visible: root.activeMode === "off"
                            spacing: 8
                            Text {
                                text: "Les servomoteurs des gâchettes sont désactivés. La course des gâchettes reste fluide avec la résistance du ressort standard."
                                color: ExpressiveTokens.textSurfaceMuted
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                font.pixelSize: 13
                            }
                        }

                        // Mode Feedback
                        ColumnLayout {
                            visible: root.activeMode === "feedback"
                            spacing: 12
                            Layout.fillWidth: true

                            RowLayout {
                                Text { text: "Position de départ du mur (0-9)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 0; to: 9; value: root.fbPos; onMoved: function(v){ root.fbPos = Math.round(v) } }
                            }
                            RowLayout {
                                Text { text: "Force de résistance (1-8)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 1; to: 8; value: root.fbStr; onMoved: function(v){ root.fbStr = Math.round(v) } }
                            }
                        }

                        // Mode Weapon
                        ColumnLayout {
                            visible: root.activeMode === "weapon"
                            spacing: 12
                            Layout.fillWidth: true

                            RowLayout {
                                Text { text: "Début de la détente (2-7)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 2; to: 7; value: root.wpStart; onMoved: function(v){ root.wpStart = Math.round(v); if(root.wpStop <= root.wpStart) root.wpStop = root.wpStart + 1 } }
                            }
                            RowLayout {
                                Text { text: "Rupture du coup sec (Stop: 3-8)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: root.wpStart + 1; to: 8; value: root.wpStop; onMoved: function(v){ root.wpStop = Math.round(v) } }
                            }
                            RowLayout {
                                Text { text: "Dureté de l'actionnement (1-8)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 1; to: 8; value: root.wpStr; onMoved: function(v){ root.wpStr = Math.round(v) } }
                            }
                        }

                        // Mode Bow
                        ColumnLayout {
                            visible: root.activeMode === "bow"
                            spacing: 12
                            Layout.fillWidth: true

                            RowLayout {
                                Text { text: "Début d'étirement (0-8)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 0; to: 8; value: root.bowStart; onMoved: function(v){ root.bowStart = Math.round(v); if(root.bowStop <= root.bowStart) root.bowStop = root.bowStart + 1 } }
                            }
                            RowLayout {
                                Text { text: "Fin de traction (Stop: 1-8)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: root.bowStart + 1; to: 8; value: root.bowStop; onMoved: function(v){ root.bowStop = Math.round(v) } }
                            }
                            RowLayout {
                                Text { text: "Tension de corde (1-8)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 1; to: 8; value: root.bowStr; onMoved: function(v){ root.bowStr = Math.round(v) } }
                            }
                            RowLayout {
                                Text { text: "Force de relâche (Snap: 1-8)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 1; to: 8; value: root.bowSnap; onMoved: function(v){ root.bowSnap = Math.round(v) } }
                            }
                        }

                        // Mode Machine
                        ColumnLayout {
                            visible: root.activeMode === "machine"
                            spacing: 10
                            Layout.fillWidth: true

                            RowLayout {
                                Text { text: "Course Début / Fin"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 1; to: 7; value: root.mStart; onMoved: function(v){ root.mStart = Math.round(v) } }
                                ExpressiveSlider { Layout.fillWidth: true; from: 2; to: 8; value: root.mStop; onMoved: function(v){ root.mStop = Math.round(v) } }
                            }
                            RowLayout {
                                Text { text: "Forces A & B (0-7)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 0; to: 7; value: root.mStrA; onMoved: function(v){ root.mStrA = Math.round(v) } }
                                ExpressiveSlider { Layout.fillWidth: true; from: 0; to: 7; value: root.mStrB; onMoved: function(v){ root.mStrB = Math.round(v) } }
                            }
                            RowLayout {
                                Text { text: "Fréquence (1-20 Hz)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 1; to: 20; value: root.mFreq; onMoved: function(v){ root.mFreq = Math.round(v) } }
                            }
                        }

                        // Mode Galloping
                        ColumnLayout {
                            visible: root.activeMode === "galloping"
                            spacing: 12
                            Layout.fillWidth: true

                            RowLayout {
                                Text { text: "Battements Pied 1 & 2"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 0; to: 8; value: root.galF1; onMoved: function(v){ root.galF1 = Math.round(v) } }
                                ExpressiveSlider { Layout.fillWidth: true; from: 1; to: 8; value: root.galF2; onMoved: function(v){ root.galF2 = Math.round(v) } }
                            }
                            RowLayout {
                                Text { text: "Cadence (1-8 Hz)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 1; to: 8; value: root.galFreq; onMoved: function(v){ root.galFreq = Math.round(v) } }
                            }
                        }

                        // Mode Vibration
                        ColumnLayout {
                            visible: root.activeMode === "vibration"
                            spacing: 12
                            Layout.fillWidth: true

                            RowLayout {
                                Text { text: "Position centrale (0-9)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 0; to: 9; value: root.vibPos; onMoved: function(v){ root.vibPos = Math.round(v) } }
                            }
                            RowLayout {
                                Text { text: "Amplitude d'oscillation (1-8)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 1; to: 8; value: root.vibAmp; onMoved: function(v){ root.vibAmp = Math.round(v) } }
                            }
                            RowLayout {
                                Text { text: "Fréquence moteur (1-40 Hz)"; color: ExpressiveTokens.textSurface; Layout.preferredWidth: 200; font.pixelSize: 12 }
                                ExpressiveSlider { Layout.fillWidth: true; from: 1; to: 40; value: root.vibFreq; onMoved: function(v){ root.vibFreq = Math.round(v) } }
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // Action Apply button
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            ExpressiveButton {
                                Layout.fillWidth: true
                                text: "⚡ Appliquer l'effet aux gâchettes"
                                variant: "primary"
                                onClicked: root.applyCurrentMode()
                            }
                            ExpressiveButton {
                                text: "Réinitialiser (Off)"
                                variant: "outlined"
                                onClicked: dualsense.setTriggerOff(root.targetTrigger)
                            }
                        }
                    }
                }

                // Visualizer Curve Panel
                ExpressiveCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 330
                    cardColor: ExpressiveTokens.surfaceContainer

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "📈 COURBE FORCE / DÉPLACEMENT EN DIRECT"
                                color: ExpressiveTokens.textSurfaceMuted
                                font.family: ExpressiveTokens.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.Bold
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "Course : 0% → 100%"
                                color: ExpressiveTokens.secondary
                                font.family: ExpressiveTokens.fontMono
                                font.pixelSize: 11
                            }
                        }

                        TriggerVisualizer {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            mode: root.activeMode
                            param1: {
                                if (root.activeMode === "feedback") return root.fbPos
                                if (root.activeMode === "weapon") return root.wpStart
                                if (root.activeMode === "bow") return root.bowStart
                                if (root.activeMode === "machine") return root.mStart
                                if (root.activeMode === "galloping") return root.galF1
                                if (root.activeMode === "vibration") return root.vibPos
                                return 0
                            }
                            param2: {
                                if (root.activeMode === "feedback") return root.fbStr
                                if (root.activeMode === "weapon") return root.wpStop
                                if (root.activeMode === "bow") return root.bowStop
                                if (root.activeMode === "machine") return root.mStop
                                if (root.activeMode === "galloping") return root.galF2
                                if (root.activeMode === "vibration") return root.vibAmp
                                return 0
                            }
                            param3: {
                                if (root.activeMode === "weapon") return root.wpStr
                                if (root.activeMode === "bow") return root.bowStr
                                if (root.activeMode === "machine") return root.mStrA
                                if (root.activeMode === "vibration") return root.vibFreq
                                return 0
                            }
                            param4: {
                                if (root.activeMode === "bow") return root.bowSnap
                                if (root.activeMode === "machine") return root.mStrB
                                return 0
                            }
                            traceColor: ExpressiveTokens.primary
                        }

                        Text {
                            text: "Le point blanc animé simule la progression de la pression du joueur sur la gâchette."
                            color: ExpressiveTokens.textSurfaceMuted
                            font.pixelSize: 11
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}
