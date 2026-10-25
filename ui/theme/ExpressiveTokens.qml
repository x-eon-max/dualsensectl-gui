import QtQuick

QtObject {
    id: tokens

    // Material 3 Expressive Dark Gaming Palette
    readonly property color surface: "#0B0D13"
    readonly property color surfaceContainerLowest: "#0F111A"
    readonly property color surfaceContainerLow: "#151724"
    readonly property color surfaceContainer: "#1C1F30"
    readonly property color surfaceContainerHigh: "#23273D"
    readonly property color surfaceContainerHighest: "#2C314C"
    readonly property color surfaceDim: "#12141F"
    readonly property color surfaceBright: "#333854"

    readonly property color outline: "#3E4460"
    readonly property color outlineVariant: "#25293B"

    readonly property color textSurface: "#E3E3EC"
    readonly property color textSurfaceVariant: "#A3A7BD"
    readonly property color textSurfaceMuted: "#6B708A"

    // Expressive DualSense & Gaming Accents
    readonly property color primary: "#388BFF"              // PlayStation Electric Blue
    readonly property color primaryContainer: "#122A5E"
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textPrimaryContainer: "#D3E4FF"

    readonly property color secondary: "#00E5FF"            // Cyan Neon
    readonly property color secondaryContainer: "#004B57"
    readonly property color textSecondary: "#001F26"

    readonly property color tertiary: "#FF3B77"             // Cosmic Pink / Magenta
    readonly property color tertiaryContainer: "#5F0E2A"
    readonly property color textTertiary: "#FFFFFF"

    readonly property color amberWarning: "#FF8C00"         // Amber DualSense Mic Mute
    readonly property color warningColor: "#FF8C00"
    readonly property color colorWarning: "#FF8C00"

    readonly property color successColor: "#00E676"         // Emerald Connected
    readonly property color colorSuccess: "#00E676"

    readonly property color errorColor: "#FF5449"
    readonly property color colorError: "#FF5449"

    // Expressive Radiuses
    readonly property real radiusPill: 9999
    readonly property real radiusXLarge: 28
    readonly property real radiusLarge: 20
    readonly property real radiusMedium: 16
    readonly property real radiusSmall: 10
    readonly property real radiusXSmall: 6

    // Motion Durations (ms)
    readonly property int durationFast: 150
    readonly property int durationNormal: 250
    readonly property int durationSlow: 400

    // Typography Fonts
    readonly property string fontFamily: "Inter, Roboto, system-ui, sans-serif"
    readonly property string fontMono: "JetBrains Mono, Fira Code, monospace"

    // Ambient glow helper
    function glowColor(baseColor, alpha) {
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alpha !== undefined ? alpha : 0.25)
    }

    // Color to HEX string
    function toHex(color) {
        var r = Math.round(color.r * 255).toString(16).padStart(2, '0').toUpperCase()
        var g = Math.round(color.g * 255).toString(16).padStart(2, '0').toUpperCase()
        var b = Math.round(color.b * 255).toString(16).padStart(2, '0').toUpperCase()
        return "#" + r + g + b
    }
}
