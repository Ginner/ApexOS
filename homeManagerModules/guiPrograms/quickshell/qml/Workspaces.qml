import QtQuick
import Quickshell.WindowManager

Row {
    spacing: 4
    height: Settings.height - 4
    Repeater {
        // Retain hidden workspaces, as in the old ignore-hidden=false configuration.
        model: [...WindowManager.windowsets].sort((a, b) => a.name.localeCompare(b.name, undefined, { numeric: true }))
        Item {
            id: workspace
            required property var modelData
            width: Math.max(30, label.implicitWidth + 20)
            height: Settings.height - 4
            readonly property color indicator: modelData.active ? Settings.accent
                : modelData.urgent ? Settings.warning : Settings.foreground
            Hexagon {
                anchors.fill: parent
                anchors.margins: 1
                fillColor: mouse.containsMouse ? Settings.muted : "transparent"
                lineColor: workspace.indicator
                lineWidth: 1.3
            }
            Text {
                id: label
                anchors.centerIn: parent
                text: workspace.modelData.name
                textFormat: Text.PlainText
                font.family: Settings.data.fontFamily
                font.pixelSize: Math.max(10, Settings.data.fontSize - 2)
                font.bold: true
                color: workspace.indicator
            }
            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (workspace.modelData.canActivate) workspace.modelData.activate()
                onWheel: event => {
                    if (event.angleDelta.y !== 0)
                        Services.run(event.angleDelta.y > 0 ? Settings.data.commands.previousWorkspace : Settings.data.commands.nextWorkspace);
                }
            }
        }
    }
}
