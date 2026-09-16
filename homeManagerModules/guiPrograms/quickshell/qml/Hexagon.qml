import QtQuick
import QtQuick.Shapes

// Flat top/bottom, pointed left/right. The same geometry serves segments and workspaces.
Shape {
    id: root
    property color fillColor: Settings.background
    property color lineColor: "transparent"
    property real lineWidth: 0
    property real tip: Math.min(height / 2, width / 4)
    antialiasing: true
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
        strokeWidth: root.lineWidth
        strokeColor: root.lineColor
        fillColor: root.fillColor
        joinStyle: ShapePath.MiterJoin
        startX: root.tip
        startY: root.lineWidth / 2
        PathLine { x: root.width - root.tip; y: root.lineWidth / 2 }
        PathLine { x: root.width - root.lineWidth / 2; y: root.height / 2 }
        PathLine { x: root.width - root.tip; y: root.height - root.lineWidth / 2 }
        PathLine { x: root.tip; y: root.height - root.lineWidth / 2 }
        PathLine { x: root.lineWidth / 2; y: root.height / 2 }
        PathLine { x: root.tip; y: root.lineWidth / 2 }
    }
}
