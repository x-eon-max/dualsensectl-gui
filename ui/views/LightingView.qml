import QtQuick
import QtQuick.Layouts
import "../components"

Item {
    id: root

    property var device: dualsense.activeDevice
    property color selectedColor: device ? device.lightbarColor : "#388BFF"
    property int brightness: device ? device.lightbarBrightness : 255
    property int playerLeds: device ? device.playerLeds : 1
    property int ledDimming: device ? device.ledBrightness : 0

    function applySelectedColor() {
        var r = Math.round(selectedColor.r * 255)
        var g = Math.round(selectedColor.g * 255)
        var b = Math.round(selectedColor.b * 255)
        dualsense.setLightbar(r, g, b, brightness)
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

            // Top Header Card
            ExpressiveCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                glowColor: root.selectedColor

                RowLayout {
                    anchors.fill: parent
                    spacing: 20

                    ColumnLayout {
                        spacing: 4
                        Text {
                            text: "🌈 RGB LIGHTING & PLAYER LEDS"
                            color: ExpressiveTokens.textSurface
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 18
                            font.weight: Font.Black
                        }
                        Text {
                            text: "Color calibration for Touchpad lightbar and numbered player indicators"
                            color: ExpressiveTokens.textSurfaceMuted
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 13
                        }
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 12
                        Text { text: "Lightbar Enabled:"; color: ExpressiveTokens.textSurface; font.weight: Font.Bold; font.pixelSize: 13 }
                        ExpressiveSwitch {
                            checked: device ? device.lightbarEnabled : true
                            onToggled: function(st) { dualsense.setLightbarEnabled(st) }
                        }
                    }
                }
            }

            // Main Studio Section: Color Wheel + Presets & Sliders
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                // Color Wheel & Real-time Hex Preview
                ExpressiveCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 380
                    cardColor: ExpressiveTokens.surfaceContainer
                    glowColor: root.selectedColor

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 16

                        Text {
                            text: "REAL-TIME HSV COLOR WHEEL"
                            color: ExpressiveTokens.textSurfaceMuted
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        ColorWheel {
                            Layout.alignment: Qt.AlignHCenter
                            currentColor: root.selectedColor
                            onColorSelected: function(col) {
                                root.selectedColor = col
                                root.applySelectedColor()
                            }
                        }

                        // Preview Pill with Hex string
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 12

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 14
                                color: root.selectedColor
                                border.color: "#FFFFFF"
                                border.width: 1.5
                            }

                            Text {
                                text: ExpressiveTokens.toHex(root.selectedColor)
                                color: ExpressiveTokens.textSurface
                                font.family: ExpressiveTokens.fontMono
                                font.pixelSize: 16
                                font.weight: Font.Bold
                            }
                        }
                    }
                }

                // Presets & Parameters Card
                ExpressiveCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 380
                    cardColor: ExpressiveTokens.surfaceContainer

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 18

                        Text {
                            text: "OFFICIAL PALETTES & BRIGHTNESS"
                            color: ExpressiveTokens.textSurfaceMuted
                            font.family: ExpressiveTokens.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        // Preset chips grid
                        GridLayout {
                            columns: 4
                            Layout.fillWidth: true
                            rowSpacing: 8
                            columnSpacing: 8

                            ExpressiveChip { text: "PS5 Blue"; activeColor: "#0070D1"; onClicked: { root.selectedColor = "#0070D1"; root.applySelectedColor() } }
                            ExpressiveChip { text: "Neon Cyan"; activeColor: "#00E5FF"; onClicked: { root.selectedColor = "#00E5FF"; root.applySelectedColor() } }
                            ExpressiveChip { text: "Cosmic Red"; activeColor: "#E91E63"; onClicked: { root.selectedColor = "#E91E63"; root.applySelectedColor() } }
                            ExpressiveChip { text: "Nova Pink"; activeColor: "#FF4081"; onClicked: { root.selectedColor = "#FF4081"; root.applySelectedColor() } }
                            ExpressiveChip { text: "Galactic Purple"; activeColor: "#9C27B0"; onClicked: { root.selectedColor = "#9C27B0"; root.applySelectedColor() } }
                            ExpressiveChip { text: "Astro White"; activeColor: "#FFFFFF"; onClicked: { root.selectedColor = "#FFFFFF"; root.applySelectedColor() } }
                            ExpressiveChip { text: "Emerald Green"; activeColor: "#00E676"; onClicked: { root.selectedColor = "#00E676"; root.applySelectedColor() } }
                            ExpressiveChip { text: "Stealth Amber"; activeColor: "#FF8C00"; onClicked: { root.selectedColor = "#FF8C00"; root.applySelectedColor() } }
                        }

                        // Brightness Slider
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Master Lightbar Brightness"; color: ExpressiveTokens.textSurface; font.pixelSize: 13; font.weight: Font.Medium }
                                Item { Layout.fillWidth: true }
                                Text { text: Math.round((root.brightness / 255.0) * 100) + "%"; color: ExpressiveTokens.primary; font.family: ExpressiveTokens.fontMono; font.weight: Font.Bold; font.pixelSize: 13 }
                            }
                            ExpressiveSlider {
                                Layout.fillWidth: true
                                from: 0; to: 255
                                value: root.brightness
                                onMoved: function(v) {
                                    root.brightness = Math.round(v)
                                    root.applySelectedColor()
                                }
                            }
                        }

                        // Player LEDs Selection
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text { text: "Player Number LEDs (1 to 5):"; color: ExpressiveTokens.textSurface; font.pixelSize: 13; font.weight: Font.Medium }
                            RowLayout {
                                spacing: 8
                                ExpressiveChip { text: "0 (Off)"; selected: root.playerLeds === 0; onClicked: { root.playerLeds = 0; dualsense.setPlayerLeds(0) } }
                                ExpressiveChip { text: "1 LED"; selected: root.playerLeds === 1; onClicked: { root.playerLeds = 1; dualsense.setPlayerLeds(1) } }
                                ExpressiveChip { text: "2 LEDs"; selected: root.playerLeds === 2; onClicked: { root.playerLeds = 2; dualsense.setPlayerLeds(2) } }
                                ExpressiveChip { text: "3 LEDs"; selected: root.playerLeds === 3; onClicked: { root.playerLeds = 3; dualsense.setPlayerLeds(3) } }
                                ExpressiveChip { text: "4 LEDs"; selected: root.playerLeds === 4; onClicked: { root.playerLeds = 4; dualsense.setPlayerLeds(4) } }
                                ExpressiveChip { text: "5 LEDs"; selected: root.playerLeds === 5; onClicked: { root.playerLeds = 5; dualsense.setPlayerLeds(5) } }
                            }
                        }

                        // Dimming Level
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            Text { text: "Player LEDs Dimming:"; color: ExpressiveTokens.textSurface; font.pixelSize: 13; font.weight: Font.Medium }
                            ExpressiveChip { text: "Bright (High)"; selected: root.ledDimming === 0; onClicked: { root.ledDimming = 0; dualsense.setLedBrightness(0) } }
                            ExpressiveChip { text: "Medium"; selected: root.ledDimming === 1; onClicked: { root.ledDimming = 1; dualsense.setLedBrightness(1) } }
                            ExpressiveChip { text: "Dim (Low)"; selected: root.ledDimming === 2; onClicked: { root.ledDimming = 2; dualsense.setLedBrightness(2) } }
                        }
                    }
                }
            }
        }
    }
}
