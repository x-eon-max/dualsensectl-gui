import QtQuick

Rectangle {
    id: root

    property string message: ""
    property string toastType: "info" // "info", "success", "warning", "error"

    function show(msg, type) {
        message = msg
        toastType = type || "info"
        opacity = 1.0
        hideTimer.restart()
    }

    implicitWidth: Math.max(200, toastRow.implicitWidth + 32)
    implicitHeight: 44
    radius: height / 2
    color: ExpressiveTokens.surfaceContainerHighest
    border.color: {
        switch (toastType) {
            case "success": return ExpressiveTokens.successColor
            case "warning": return ExpressiveTokens.warningColor
            case "error":   return ExpressiveTokens.errorColor
            default:        return ExpressiveTokens.primary
        }
    }
    border.width: 1.5

    opacity: 0.0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: ExpressiveTokens.durationNormal; easing.type: Easing.OutCubic }
    }

    Row {
        id: toastRow
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: {
                switch (root.toastType) {
                    case "success": return "✓"
                    case "warning": return "⚠️"
                    case "error":   return "✕"
                    default:        return "ℹ"
                }
            }
            color: {
                switch (root.toastType) {
                    case "success": return ExpressiveTokens.successColor
                    case "warning": return ExpressiveTokens.warningColor
                    case "error":   return ExpressiveTokens.errorColor
                    default:        return ExpressiveTokens.primary
                }
            }
            font.pixelSize: 14
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.message
            color: ExpressiveTokens.textSurface
            font.family: ExpressiveTokens.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Timer {
        id: hideTimer
        interval: 3200
        onTriggered: root.opacity = 0.0
    }
}
