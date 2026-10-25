import QtQuick

Item {
    id: root

    property string mode: "weapon" // "off", "feedback", "weapon", "bow", "machine", "galloping", "vibration"
    property real param1: 2
    property real param2: 5
    property real param3: 7
    property real param4: 8
    property real param5: 10
    property real param6: 2
    property color traceColor: ExpressiveTokens.primary

    implicitWidth: 320
    implicitHeight: 140

    // Background Container
    Rectangle {
        anchors.fill: parent
        radius: ExpressiveTokens.radiusMedium
        color: ExpressiveTokens.surfaceContainerLowest
        border.color: ExpressiveTokens.outlineVariant
        border.width: 1

        // Grid lines
        Canvas {
            id: graphCanvas
            anchors.fill: parent
            anchors.margins: 12
            renderStrategy: Canvas.Threaded

            property real animPhase: 0

            NumberAnimation on animPhase {
                from: 0; to: 1.0; duration: 2400; loops: Animation.Infinite
            }
            onAnimPhaseChanged: graphCanvas.requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                var pad = 6
                var w = width - pad * 2
                var h = height - pad * 2

                // Horizontal dashed grid lines
                ctx.strokeStyle = "#1F2335"
                ctx.lineWidth = 1
                ctx.setLineDash([4, 4])
                for (var g = 1; g <= 3; ++g) {
                    var gy = pad + (h / 4) * g
                    ctx.beginPath()
                    ctx.moveTo(pad, gy)
                    ctx.lineTo(pad + w, gy)
                    ctx.stroke()
                }
                ctx.setLineDash([])

                // Baseline
                ctx.strokeStyle = "#2C314C"
                ctx.lineWidth = 1.5
                ctx.beginPath()
                ctx.moveTo(pad, pad + h)
                ctx.lineTo(pad + w, pad + h)
                ctx.stroke()

                // Calculate curve points
                ctx.strokeStyle = root.traceColor
                ctx.lineWidth = 2.5
                ctx.beginPath()

                var numPoints = 100
                var maxForce = 8.0

                for (var i = 0; i <= numPoints; ++i) {
                    var xPct = i / numPoints // 0.0 to 1.0 (trigger travel: 0 = untouched, 1 = bottomed out)
                    var posIdx = xPct * 9.0 // 0 to 9 travel scale
                    var force = 0.5 // baseline low spring resistance

                    switch (root.mode) {
                        case "off":
                            force = 0.5 + 0.5 * xPct
                            break

                        case "feedback":
                            // pos: param1, strength: param2
                            if (posIdx >= root.param1) {
                                force = root.param2
                            } else {
                                force = 0.5
                            }
                            break

                        case "weapon":
                            // start: param1, stop: param2, strength: param3
                            if (posIdx < root.param1) {
                                force = 0.5 + (posIdx / root.param1) * 1.0
                            } else if (posIdx >= root.param1 && posIdx < root.param2) {
                                force = root.param3 // High resistance wall before break
                            } else {
                                force = 1.0 // Trigger break drop!
                            }
                            break

                        case "bow":
                            // start: param1, stop: param2, strength: param3, snap: param4
                            if (posIdx < root.param1) {
                                force = 0.5
                            } else if (posIdx >= root.param1 && posIdx < root.param2) {
                                var drawProgress = (posIdx - root.param1) / Math.max(0.1, (root.param2 - root.param1))
                                force = 0.5 + drawProgress * root.param3
                            } else {
                                force = Math.max(0.5, root.param3 - root.param4 * 0.8)
                            }
                            break

                        case "machine":
                            // start: param1, stop: param2, strA: param3, strB: param4, freq: param5
                            if (posIdx >= root.param1 && posIdx <= root.param2) {
                                var osc = Math.sin((posIdx + animPhase * 4) * Math.PI * 3)
                                force = (osc > 0) ? root.param4 : root.param3
                            } else {
                                force = 0.5
                            }
                            break

                        case "galloping":
                            // start: param1, stop: param2, f1: param3, f2: param4
                            if (posIdx >= root.param1 && posIdx <= root.param2) {
                                var d1 = Math.abs(posIdx - root.param3)
                                var d2 = Math.abs(posIdx - root.param4)
                                if (d1 < 0.6) force = 7.0 * (1.0 - d1 / 0.6)
                                else if (d2 < 0.6) force = 5.5 * (1.0 - d2 / 0.6)
                                else force = 1.0
                            }
                            break

                        case "vibration":
                            // pos: param1, amp: param2, freq: param3
                            var dist = Math.abs(posIdx - root.param1)
                            if (dist < 2.5) {
                                var vibOsc = Math.sin((posIdx + animPhase * 6) * Math.PI * 4)
                                force = 2.0 + vibOsc * (root.param2 * 0.5)
                            } else {
                                force = 0.5
                            }
                            break

                        default:
                            force = 0.5
                            break
                    }

                    var px = pad + xPct * w
                    var py = pad + h - (Math.min(maxForce, Math.max(0, force)) / maxForce) * h

                    if (i === 0) ctx.moveTo(px, py)
                    else ctx.lineTo(px, py)
                }

                ctx.stroke()

                // Animated Trigger Cursor Probe
                var probePct = (animPhase < 0.5) ? (animPhase * 2) : ((1.0 - animPhase) * 2)
                var probeX = pad + probePct * w

                ctx.fillStyle = "#FFFFFF"
                ctx.beginPath()
                ctx.arc(probeX, pad + h - 4, 3, 0, 2 * Math.PI)
                ctx.fill()
            }
        }
    }

    onModeChanged: graphCanvas.requestPaint()
    onParam1Changed: graphCanvas.requestPaint()
    onParam2Changed: graphCanvas.requestPaint()
    onParam3Changed: graphCanvas.requestPaint()
    onParam4Changed: graphCanvas.requestPaint()
}
