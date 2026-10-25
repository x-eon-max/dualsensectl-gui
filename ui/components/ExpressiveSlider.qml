import QtQuick

Item {
    id: root

    property real from: 0
    property real to: 100
    property real value: 50
    property string unit: ""
    property color activeColor: ExpressiveTokens.primary

    signal moved(real val)

    implicitWidth: 260
    implicitHeight: 48

    // Track background
    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 16
        radius: 8
        color: ExpressiveTokens.surfaceContainerHighest
        clip: true

        // Filled active progress
        Rectangle {
            id: progress
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(8, thumb.x + thumb.width / 2)
            radius: 8
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.darker(root.activeColor, 1.25) }
                GradientStop { position: 1.0; color: root.activeColor }
            }
        }
    }

    // Draggable Thumb
    Rectangle {
        id: thumb
        x: {
            var range = root.to - root.from
            if (range <= 0) return 0
            var pct = Math.max(0, Math.min(1, (root.value - root.from) / range))
            return pct * (root.width - width)
        }
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        height: 28
        radius: 8
        color: "#FFFFFF"

        scale: mouseArea.drag.active ? 1.15 : (mouseArea.containsMouse ? 1.08 : 1.0)
        Behavior on scale {
            NumberAnimation { duration: ExpressiveTokens.durationFast; easing.type: Easing.OutBack }
        }

        // Inner accent stripe
        Rectangle {
            anchors.centerIn: parent
            width: 4
            height: 14
            radius: 2
            color: root.activeColor
        }

        // Value tooltip bubble
        Rectangle {
            id: bubble
            visible: mouseArea.drag.active || mouseArea.containsMouse
            anchors.bottom: parent.top
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            width: bubbleText.implicitWidth + 14
            height: 24
            radius: 12
            color: ExpressiveTokens.surfaceContainerHighest
            border.color: ExpressiveTokens.outline
            border.width: 1

            Text {
                id: bubbleText
                anchors.centerIn: parent
                text: Math.round(root.value) + root.unit
                color: ExpressiveTokens.textSurface
                font.family: ExpressiveTokens.fontMono
                font.pixelSize: 11
                font.weight: Font.Bold
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function updateFromMouse(mouseX) {
            var usableWidth = root.width - thumb.width
            var clampedX = Math.max(0, Math.min(usableWidth, mouseX - thumb.width / 2))
            var pct = clampedX / usableWidth
            var newVal = root.from + pct * (root.to - root.from)
            root.value = newVal
            root.moved(newVal)
        }

        onPressed: updateFromMouse(mouse.x)
        onPositionChanged: {
            if (pressed) {
                updateFromMouse(mouse.x)
            }
        }
    }
}
