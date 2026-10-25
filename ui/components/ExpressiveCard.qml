import QtQuick

Item {
    id: root

    property color cardColor: ExpressiveTokens.surfaceContainer
    property color glowColor: "transparent"
    property real cardRadius: ExpressiveTokens.radiusXLarge
    property color borderColor: ExpressiveTokens.outlineVariant
    property bool interactive: false
    property bool hovered: mouseArea.containsMouse
    property bool pressed: mouseArea.pressed

    signal clicked()

    default property alias content: container.children

    implicitWidth: 320
    implicitHeight: 200

    // Ambient Glow Background
    Rectangle {
        id: glowEffect
        anchors.fill: cardBg
        anchors.margins: -6
        radius: root.cardRadius + 6
        color: root.glowColor
        opacity: root.glowColor !== "transparent" ? (root.hovered ? 0.50 : 0.28) : 0.0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: ExpressiveTokens.durationNormal; easing.type: Easing.OutCubic }
        }
    }

    // Main Card Surface
    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: root.cardRadius
        color: root.interactive && root.hovered ? ExpressiveTokens.surfaceContainerHigh : root.cardColor
        border.color: root.interactive && root.hovered ? ExpressiveTokens.primary : root.borderColor
        border.width: 1

        scale: root.interactive && root.pressed ? 0.98 : (root.interactive && root.hovered ? 1.01 : 1.0)

        Behavior on scale {
            NumberAnimation { duration: ExpressiveTokens.durationFast; easing.type: Easing.OutCubic }
        }
        Behavior on color {
            ColorAnimation { duration: ExpressiveTokens.durationNormal }
        }
        Behavior on border.color {
            ColorAnimation { duration: ExpressiveTokens.durationNormal }
        }

        Item {
            id: container
            anchors.fill: parent
            anchors.margins: 16
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            enabled: root.interactive
            hoverEnabled: true
            cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.clicked()
        }
    }
}
