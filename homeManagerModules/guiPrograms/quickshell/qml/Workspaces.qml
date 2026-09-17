import QtQuick
import Quickshell.Hyprland
import Quickshell.WindowManager

Row {
    id: root
    property var workspaces: WindowManager.windowsets
    property string focusedWorkspaceName: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.name : ""
    readonly property var orderedWorkspaces: [...workspaces].sort((a, b) => {
        // QML's localeCompare does not implement the JS Intl numeric option.
        const aNumeric = /^\d+$/.test(a.name);
        const bNumeric = /^\d+$/.test(b.name);
        if (aNumeric && bNumeric) return Number(a.name) - Number(b.name);
        if (aNumeric !== bNumeric) return aNumeric ? -1 : 1;
        return a.name.localeCompare(b.name);
    })
    spacing: 4
    height: Settings.height - 4
    Repeater {
        // Retain hidden workspaces, as in the old ignore-hidden=false configuration.
        model: root.orderedWorkspaces
        Item {
            id: workspace
            objectName: "workspace-indicator"
            required property var modelData
            readonly property string displayName: modelData.name === "10" ? "0" : modelData.name
            readonly property bool focused: modelData.name === root.focusedWorkspaceName
            width: Math.max(30, label.implicitWidth + 20)
            height: Settings.height - 4
            // ext-workspace's active state means visible on ANY monitor.
            readonly property color outlineColor: modelData.active ? Settings.accent
                : modelData.urgent ? Settings.warning : Settings.foreground
            readonly property color digitColor: focused ? Settings.accent : Settings.foreground
            Hexagon {
                anchors.fill: parent
                anchors.margins: 1
                fillColor: mouse.containsMouse ? Settings.muted : "transparent"
                lineColor: workspace.outlineColor
                lineWidth: 1.3
            }
            Text {
                id: label
                anchors.centerIn: parent
                text: workspace.displayName
                textFormat: Text.PlainText
                font.family: Settings.data.fontFamily
                font.pixelSize: Math.max(10, Settings.data.fontSize - 2)
                font.bold: true
                color: workspace.digitColor
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
