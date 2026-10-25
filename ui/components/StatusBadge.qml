import QtQuick

Rectangle {
    id: root

    property string text: ""
    property color dotColor: ExpressiveTokens.successColor
    property bool pulsing: false

    implicitWidth: badgeRow.implicitWidth + 20
    implicitHeight: 28
    radius: height / 2
    color: ExpressiveTokens.surfaceContainerHigh
    border.color: ExpressiveTokens.outlineVariant
    border.width: 1

    Row {
        id: badgeRow
        anchors.centerIn: parent
        spacing: 8

        Rectangle {
            id: statusDot
            width: 8
            height: 8
            radius: 4
            color: root.dotColor
            anchors.verticalCenter: parent.verticalCenter

            SequentialAnimation on opacity {
                running: root.pulsing
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.3; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.3; to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
            }
        }

        Text {
            text: root.text
            color: ExpressiveTokens.textSurface
            font.family: ExpressiveTokens.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
