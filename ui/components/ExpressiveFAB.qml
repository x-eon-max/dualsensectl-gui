import QtQuick

Item {
    id: root

    property bool expanded: false
    signal quickMuteRequested()
    signal powerOffRequested()
    signal rescanRequested()

    width: 60
    height: expanded ? 190 : 60

    // Background scrim if expanded
    MouseArea {
        anchors.fill: parent
        enabled: root.expanded
        onClicked: root.expanded = false
    }

    // Mini action 1: Quick Mute
    Rectangle {
        id: actionMute
        width: 44
        height: 44
        radius: 22
        anchors.horizontalCenter: mainFab.horizontalCenter
        y: root.expanded ? 10 : 80
        opacity: root.expanded ? 1.0 : 0.0
        color: ExpressiveTokens.amberWarning
        scale: mouseMute.pressed ? 0.92 : 1.0

        Behavior on y { NumberAnimation { duration: ExpressiveTokens.durationNormal; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: ExpressiveTokens.durationFast } }

        Text {
            anchors.centerIn: parent
            text: "🎙"
            font.pixelSize: 18
        }

        MouseArea {
            id: mouseMute
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.quickMuteRequested()
                root.expanded = false
            }
        }
    }

    // Mini action 2: Power Off BT
    Rectangle {
        id: actionPower
        width: 44
        height: 44
        radius: 22
        anchors.horizontalCenter: mainFab.horizontalCenter
        y: root.expanded ? 64 : 80
        opacity: root.expanded ? 1.0 : 0.0
        color: ExpressiveTokens.errorColor
        scale: mousePower.pressed ? 0.92 : 1.0

        Behavior on y { NumberAnimation { duration: ExpressiveTokens.durationNormal; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: ExpressiveTokens.durationFast } }

        Text {
            anchors.centerIn: parent
            text: "🔌"
            font.pixelSize: 16
        }

        MouseArea {
            id: mousePower
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.powerOffRequested()
                root.expanded = false
            }
        }
    }

    // Main Floating Action Button
    Rectangle {
        id: mainFab
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 56
        height: 56
        radius: 28
        color: ExpressiveTokens.primary

        scale: mouseMain.pressed ? 0.92 : (mouseMain.containsMouse ? 1.05 : 1.0)
        Behavior on scale { NumberAnimation { duration: ExpressiveTokens.durationFast; easing.type: Easing.OutBack } }

        // Icon (rotating + / x or lightning)
        Text {
            anchors.centerIn: parent
            text: root.expanded ? "✕" : "⚡"
            color: "#FFFFFF"
            font.pixelSize: 22
            font.weight: Font.Black
            rotation: root.expanded ? 90 : 0
            Behavior on rotation { NumberAnimation { duration: ExpressiveTokens.durationNormal; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            id: mouseMain
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }
}
