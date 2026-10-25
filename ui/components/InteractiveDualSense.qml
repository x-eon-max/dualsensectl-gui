import QtQuick

Item {
    id: root

    property color lightbarColor: "#388BFF"
    property int lightbarBrightness: 255
    property bool lightbarEnabled: true
    property int playerLeds: 1
    property bool micMuted: false
    property string activeTrigger: "both" // "left", "right", "both", "none"

    implicitWidth: 380
    implicitHeight: 280

    // Ambient Glow Halo behind the controller
    Rectangle {
        id: ambientHalo
        anchors.centerIn: parent
        width: 320
        height: 220
        radius: 110
        color: root.lightbarEnabled ? root.lightbarColor : "transparent"
        opacity: root.lightbarEnabled ? (root.lightbarBrightness / 255.0) * 0.40 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: ExpressiveTokens.durationNormal }
        }
        Behavior on color {
            ColorAnimation { duration: ExpressiveTokens.durationFast }
        }
    }

    // Main Controller SVG / Canvas
    Canvas {
        id: controllerCanvas
        anchors.fill: parent
        renderStrategy: Canvas.Threaded

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            var cx = width / 2
            var cy = height / 2

            // Scaling factor
            var scale = Math.min(width / 380, height / 280)
            ctx.save()
            ctx.translate(cx, cy)
            ctx.scale(scale, scale)

            // Top Bumpers (L1/L2 and R1/R2)
            ctx.fillStyle = (root.activeTrigger === "left" || root.activeTrigger === "both") ? "#388BFF" : "#1A1D2E"
            ctx.beginPath()
            ctx.roundRect(-130, -100, 50, 22, [10, 10, 0, 0])
            ctx.fill()

            ctx.fillStyle = (root.activeTrigger === "right" || root.activeTrigger === "both") ? "#388BFF" : "#1A1D2E"
            ctx.beginPath()
            ctx.roundRect(80, -100, 50, 22, [10, 10, 0, 0])
            ctx.fill()

            // Outer Shell (PlayStation 5 Crisp White)
            ctx.beginPath()
            ctx.moveTo(-110, -70)
            ctx.bezierCurveTo(-90, -85, 90, -85, 110, -70)
            ctx.bezierCurveTo(155, -45, 175, 55, 145, 95)
            ctx.bezierCurveTo(125, 118, 95, 80, 70, 45)
            ctx.bezierCurveTo(55, 25, 30, 20, 0, 20)
            ctx.bezierCurveTo(-30, 20, -55, 25, -70, 45)
            ctx.bezierCurveTo(-95, 80, -125, 118, -145, 95)
            ctx.bezierCurveTo(-175, 55, -155, -45, -110, -70)
            ctx.closePath()

            var shellGrad = ctx.createLinearGradient(0, -90, 0, 100)
            shellGrad.addColorStop(0, "#F2F4F8")
            shellGrad.addColorStop(1, "#D6DCE8")
            ctx.fillStyle = shellGrad
            ctx.fill()
            ctx.lineWidth = 2
            ctx.strokeStyle = "#25293B"
            ctx.stroke()

            // Inner Grip / Center Faceplate (Dark Obsidian)
            ctx.beginPath()
            ctx.moveTo(-85, -45)
            ctx.bezierCurveTo(-70, -60, 70, -60, 85, -45)
            ctx.bezierCurveTo(105, -20, 115, 60, 100, 85)
            ctx.bezierCurveTo(85, 100, 68, 70, 50, 30)
            ctx.bezierCurveTo(40, 15, -40, 15, -50, 30)
            ctx.bezierCurveTo(-68, 70, -85, 100, -100, 85)
            ctx.bezierCurveTo(-115, 60, -105, -20, -85, -45)
            ctx.closePath()
            ctx.fillStyle = "#121520"
            ctx.fill()

            // Touchpad Rect
            ctx.beginPath()
            ctx.roundRect(-48, -72, 96, 56, 8)
            ctx.fillStyle = "#1A1D2E"
            ctx.fill()
            ctx.lineWidth = 1
            ctx.strokeStyle = "#2C314C"
            ctx.stroke()

            // Reactive Lightbar Wings
            if (root.lightbarEnabled) {
                var alpha = (root.lightbarBrightness / 255.0)
                var lbColor = root.lightbarColor
                var rgba = "rgba(" + Math.round(lbColor.r * 255) + "," + Math.round(lbColor.g * 255) + "," + Math.round(lbColor.b * 255) + "," + alpha + ")"

                ctx.lineWidth = 4
                ctx.strokeStyle = rgba
                ctx.lineCap = "round"

                // Left Wing
                ctx.beginPath()
                ctx.moveTo(-52, -70)
                ctx.bezierCurveTo(-52, -40, -42, -18, -36, -16)
                ctx.stroke()

                // Right Wing
                ctx.beginPath()
                ctx.moveTo(52, -70)
                ctx.bezierCurveTo(52, -40, 42, -18, 36, -16)
                ctx.stroke()
            }

            // Player LEDs (Underneath Touchpad)
            var pLeds = root.playerLeds
            var dotY = -12
            var ledPositions = [
                [0],                       // 1 LED: Center
                [-8, 8],                   // 2 LEDs
                [-14, 0, 14],              // 3 LEDs
                [-20, -7, 7, 20],          // 4 LEDs
                [-24, -12, 0, 12, 24]      // 5 LEDs
            ]
            var activeDots = (pLeds >= 1 && pLeds <= 5) ? ledPositions[pLeds - 1] : []

            for (var i = 0; i < activeDots.length; ++i) {
                ctx.beginPath()
                ctx.arc(activeDots[i], dotY, 2, 0, 2 * Math.PI)
                ctx.fillStyle = "#FFFFFF"
                ctx.fill()
            }

            // Mic Mute Button LED (Amber when muted)
            ctx.beginPath()
            ctx.roundRect(-7, -4, 14, 6, 3)
            ctx.fillStyle = root.micMuted ? "#FF8C00" : "#2C314C"
            ctx.fill()

            // PS Home Button
            ctx.beginPath()
            ctx.arc(0, 8, 7, 0, 2 * Math.PI)
            ctx.fillStyle = "#1E2235"
            ctx.fill()
            ctx.lineWidth = 1
            ctx.strokeStyle = "#388BFF"
            ctx.stroke()

            // Left D-Pad
            ctx.beginPath()
            ctx.arc(-80, -22, 18, 0, 2 * Math.PI)
            ctx.fillStyle = "#1A1D2E"
            ctx.fill()
            ctx.fillStyle = "#58A6FF"
            ctx.fillRect(-83, -34, 6, 24)
            ctx.fillRect(-92, -25, 24, 6)

            // Right Action Buttons (Triangle, Circle, Cross, Square)
            ctx.beginPath()
            ctx.arc(80, -22, 18, 0, 2 * Math.PI)
            ctx.fillStyle = "#1A1D2E"
            ctx.fill()
            // Symbols
            ctx.fillStyle = "#00E5FF" // Triangle
            ctx.beginPath(); ctx.arc(80, -32, 2.5, 0, 2 * Math.PI); ctx.fill()
            ctx.fillStyle = "#FF3B77" // Circle
            ctx.beginPath(); ctx.arc(90, -22, 2.5, 0, 2 * Math.PI); ctx.fill()
            ctx.fillStyle = "#388BFF" // Cross
            ctx.beginPath(); ctx.arc(80, -12, 2.5, 0, 2 * Math.PI); ctx.fill()
            ctx.fillStyle = "#E24AFF" // Square
            ctx.beginPath(); ctx.arc(70, -22, 2.5, 0, 2 * Math.PI); ctx.fill()

            // Left Thumbstick
            ctx.beginPath()
            ctx.arc(-36, 32, 18, 0, 2 * Math.PI)
            ctx.fillStyle = "#0B0D13"
            ctx.fill()
            ctx.lineWidth = 2
            ctx.strokeStyle = "#388BFF"
            ctx.stroke()
            ctx.beginPath()
            ctx.arc(-36, 32, 8, 0, 2 * Math.PI)
            ctx.fillStyle = "#1C1F30"
            ctx.fill()

            // Right Thumbstick
            ctx.beginPath()
            ctx.arc(36, 32, 18, 0, 2 * Math.PI)
            ctx.fillStyle = "#0B0D13"
            ctx.fill()
            ctx.lineWidth = 2
            ctx.strokeStyle = "#388BFF"
            ctx.stroke()
            ctx.beginPath()
            ctx.arc(36, 32, 8, 0, 2 * Math.PI)
            ctx.fillStyle = "#1C1F30"
            ctx.fill()

            ctx.restore()
        }
    }

    onLightbarColorChanged: controllerCanvas.requestPaint()
    onLightbarBrightnessChanged: controllerCanvas.requestPaint()
    onLightbarEnabledChanged: controllerCanvas.requestPaint()
    onPlayerLedsChanged: controllerCanvas.requestPaint()
    onMicMutedChanged: controllerCanvas.requestPaint()
    onActiveTriggerChanged: controllerCanvas.requestPaint()
}
