import QtQuick
import QtQuick.Shapes

// Flat top/bottom, pointed left/right. The same geometry serves segments and workspaces.
Shape {
    id: root
    property color fillColor: Settings.background
    property color lineColor: "transparent"
    property real lineWidth: 0
    readonly property real inset: lineWidth / 2
    // tan(60°) = sqrt(3): all six interior angles are 120°. Account for
    // the stroke inset so outlined workspaces have the same angles as segments.
    readonly property real tip: Math.min((height - lineWidth) / (2 * Math.sqrt(3)), (width - lineWidth) / 2)
    antialiasing: true
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
        strokeWidth: root.lineWidth
        strokeColor: root.lineColor
        fillColor: root.fillColor
        joinStyle: ShapePath.MiterJoin
        startX: root.inset + root.tip
        startY: root.inset
        PathLine { x: root.width - root.inset - root.tip; y: root.inset }
        PathLine { x: root.width - root.inset; y: root.height / 2 }
        PathLine { x: root.width - root.inset - root.tip; y: root.height - root.inset }
        PathLine { x: root.inset + root.tip; y: root.height - root.inset }
        PathLine { x: root.inset; y: root.height / 2 }
        PathLine { x: root.inset + root.tip; y: root.inset }
    }
}
