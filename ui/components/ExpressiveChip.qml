import QtQuick

Rectangle {
    id: root

    property string text: ""
    property bool selected: false
    property color activeColor: ExpressiveTokens.primary
    property string iconText: ""

    signal clicked()

    implicitWidth: Math.max(64, chipRow.implicitWidth + 24)
    implicitHeight: 36
    radius: height / 2

    color: root.selected ? root.activeColor : (mouseArea.containsMouse ? ExpressiveTokens.surfaceContainerHighest : ExpressiveTokens.surfaceContainerHigh)
    border.color: root.selected ? "transparent" : (mouseArea.containsMouse ? ExpressiveTokens.outline : ExpressiveTokens.outlineVariant)
    border.width: 1

    scale: mouseArea.pressed ? 0.95 : (mouseArea.containsMouse ? 1.03 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: ExpressiveTokens.durationFast; easing.type: Easing.OutCubic }
    }
    Behavior on color {
        ColorAnimation { duration: ExpressiveTokens.durationFast }
    }

    Row {
        id: chipRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            visible: root.iconText !== ""
            text: root.iconText
            font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        // Selection dot if no icon
        Rectangle {
            visible: root.iconText === "" && root.selected
            width: 6
            height: 6
            radius: 3
            color: "#FFFFFF"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.text
            color: root.selected ? "#FFFFFF" : ExpressiveTokens.textSurface
            font.family: ExpressiveTokens.fontFamily
            font.pixelSize: 12
            font.weight: root.selected ? Font.Bold : Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
