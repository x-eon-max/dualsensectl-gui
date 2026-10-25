import QtQuick

Item {
    id: root

    property bool checked: false
    property color checkedColor: ExpressiveTokens.primary

    signal toggled(bool state)

    implicitWidth: 52
    implicitHeight: 32

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? root.checkedColor : ExpressiveTokens.surfaceContainerHighest
        border.color: root.checked ? "transparent" : ExpressiveTokens.outline
        border.width: 1.5

        Behavior on color {
            ColorAnimation { duration: ExpressiveTokens.durationFast }
        }

        // Animated thumb
        Rectangle {
            id: thumb
            width: root.checked ? 24 : 18
            height: width
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? (parent.width - width - 4) : 4
            color: root.checked ? "#FFFFFF" : ExpressiveTokens.textSurfaceMuted

            scale: mouseArea.pressed ? 1.15 : 1.0

            Behavior on x {
                NumberAnimation { duration: ExpressiveTokens.durationNormal; easing.type: Easing.OutBack }
            }
            Behavior on width {
                NumberAnimation { duration: ExpressiveTokens.durationFast; easing.type: Easing.OutCubic }
            }
            Behavior on color {
                ColorAnimation { duration: ExpressiveTokens.durationFast }
            }
            Behavior on scale {
                NumberAnimation { duration: ExpressiveTokens.durationFast; easing.type: Easing.OutBack }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
