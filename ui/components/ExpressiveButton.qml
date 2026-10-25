import QtQuick

Rectangle {
    id: root

    property string text: ""
    property string iconSource: ""
    property string variant: "primary" // "primary", "secondary", "tonal", "outlined", "danger"
    property bool pill: true
    property real customRadius: ExpressiveTokens.radiusMedium
    property color accentColor: ExpressiveTokens.primary

    signal clicked()

    implicitWidth: Math.max(92, contentRow.implicitWidth + 32)
    implicitHeight: 44
    radius: pill ? height / 2 : customRadius

    color: {
        if (!enabled) return ExpressiveTokens.surfaceContainerLow
        if (mouseArea.pressed) return Qt.darker(baseColor, 1.18)
        if (mouseArea.containsMouse) return Qt.lighter(baseColor, 1.18)
        return baseColor
    }

    border.color: {
        if (variant === "outlined") {
            return mouseArea.containsMouse ? ExpressiveTokens.primary : ExpressiveTokens.outline
        }
        return "transparent"
    }
    border.width: variant === "outlined" ? 1.5 : 0

    property color baseColor: {
        switch (variant) {
            case "primary":   return root.accentColor
            case "secondary": return ExpressiveTokens.secondary
            case "tonal":     return ExpressiveTokens.surfaceContainerHighest
            case "outlined":  return "transparent"
            case "danger":    return ExpressiveTokens.errorColor
            default:          return ExpressiveTokens.primary
        }
    }

    property color textColor: {
        if (!enabled) return ExpressiveTokens.textSurfaceMuted
        switch (variant) {
            case "primary":   return ExpressiveTokens.textPrimary
            case "secondary": return ExpressiveTokens.textSecondary
            case "tonal":     return ExpressiveTokens.textSurface
            case "outlined":  return ExpressiveTokens.primary
            case "danger":    return "#FFFFFF"
            default:          return ExpressiveTokens.textPrimary
        }
    }

    scale: mouseArea.pressed ? 0.95 : (mouseArea.containsMouse ? 1.02 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: ExpressiveTokens.durationFast; easing.type: Easing.OutCubic }
    }
    Behavior on color {
        ColorAnimation { duration: ExpressiveTokens.durationFast }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        Image {
            id: iconImg
            source: root.iconSource
            width: 20
            height: 20
            visible: root.iconSource !== ""
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
        }

        Text {
            text: root.text
            color: root.textColor
            font.family: ExpressiveTokens.fontFamily
            font.pixelSize: 13
            font.weight: Font.DemiBold
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
