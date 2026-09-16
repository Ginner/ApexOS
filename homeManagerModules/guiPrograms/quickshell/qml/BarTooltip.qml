import QtQuick
import Quickshell

PopupWindow {
    id: root
    property string text: ""
    property bool requested: false
    onRequestedChanged: if (!requested) delay.ready = false
    visible: delay.ready && requested
    color: "transparent"
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.bottom: 5
    implicitWidth: label.implicitWidth + 30
    implicitHeight: label.implicitHeight + 16
    Timer {
        id: delay
        property bool ready: false
        interval: 500
        running: root.requested
        onRunningChanged: if (!running) ready = false
        onTriggered: ready = true
    }
    Rectangle {
        anchors.fill: parent
        color: Settings.background
        border.color: Settings.muted
        Text {
            id: label
            anchors.centerIn: parent
            text: root.text
            textFormat: Text.PlainText
            color: Settings.foreground
            font.family: Settings.data.fontFamily
            font.pixelSize: Settings.data.fontSize
        }
    }
}
