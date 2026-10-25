import QtQuick

Item {
    id: root

    property color currentColor: "#388BFF"
    property real hue: 0.60
    property real saturation: 0.80
    property real brightness: 1.0

    signal colorSelected(color col)

    implicitWidth: 230
    implicitHeight: 230

    onCurrentColorChanged: {
        if (!mouseArea.pressed) {
            hue = currentColor.hsvHue
            if (hue < 0) hue = 0
            saturation = currentColor.hsvSaturation
            brightness = currentColor.hsvValue
            wheelCanvas.requestPaint()
        }
    }

    Canvas {
        id: wheelCanvas
        anchors.fill: parent
        renderStrategy: Canvas.Threaded

        onPaint: {
            var ctx = getContext("2d")
            var cx = width / 2
            var cy = height / 2
            var radius = Math.min(cx, cy) - 10

            ctx.clearRect(0, 0, width, height)

            // Draw full HSV disk with radial gradient segments
            var numSteps = 72
            var stepRad = (2 * Math.PI) / numSteps

            for (var i = 0; i < numSteps; ++i) {
                var startAngle = i * stepRad
                var endAngle = (i + 1.5) * stepRad
                var currentHue = i / numSteps

                var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, radius)
                grad.addColorStop(0, "#FFFFFF")
                grad.addColorStop(1, Qt.hsva(currentHue, 1.0, 1.0, 1.0))

                ctx.beginPath()
                ctx.moveTo(cx, cy)
                ctx.arc(cx, cy, radius, startAngle, endAngle)
                ctx.closePath()
                ctx.fillStyle = grad
                ctx.fill()
            }

            // Dark border ring
            ctx.beginPath()
            ctx.arc(cx, cy, radius, 0, 2 * Math.PI)
            ctx.lineWidth = 2
            ctx.strokeStyle = "#3E4460"
            ctx.stroke()
        }
    }

    // Interactive Selector Pin
    Rectangle {
        id: pickerPin
        width: 22
        height: 22
        radius: 11
        color: root.currentColor
        border.color: "#FFFFFF"
        border.width: 3

        x: {
            var cx = root.width / 2
            var radius = Math.min(cx, root.height / 2) - 10
            var angle = root.hue * 2 * Math.PI
            var dist = root.saturation * radius
            return cx + Math.cos(angle) * dist - width / 2
        }

        y: {
            var cy = root.height / 2
            var radius = Math.min(root.width / 2, cy) - 10
            var angle = root.hue * 2 * Math.PI
            var dist = root.saturation * radius
            return cy + Math.sin(angle) * dist - height / 2
        }

        scale: mouseArea.pressed ? 1.25 : 1.0
        Behavior on scale {
            NumberAnimation { duration: ExpressiveTokens.durationFast; easing.type: Easing.OutBack }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        function updateColor(mx, my) {
            var cx = root.width / 2
            var cy = root.height / 2
            var maxRadius = Math.min(cx, cy) - 10

            var dx = mx - cx
            var dy = my - cy
            var dist = Math.sqrt(dx * dx + dy * dy)
            var sat = Math.max(0, Math.min(1.0, dist / maxRadius))

            var angle = Math.atan2(dy, dx)
            if (angle < 0) angle += 2 * Math.PI
            var h = angle / (2 * Math.PI)

            root.hue = h
            root.saturation = sat
            root.currentColor = Qt.hsva(h, sat, root.brightness, 1.0)
            root.colorSelected(root.currentColor)
        }

        onPressed: updateColor(mouse.x, mouse.y)
        onPositionChanged: {
            if (pressed) {
                updateColor(mouse.x, mouse.y)
            }
        }
    }
}
