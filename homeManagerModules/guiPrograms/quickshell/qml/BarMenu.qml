import QtQuick
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: root
    property var entries: []
    property var stack: []
    property var currentEntries: entries
    signal selected(var entry)
    function open() {
        stack = [];
        currentEntries = entries;
        visible = true;
    }
    function back() {
        if (stack.length === 0) { visible = false; return; }
        const previous = stack.slice();
        currentEntries = previous.pop();
        stack = previous;
    }
    visible: false
    color: Settings.background
    implicitWidth: 245
    implicitHeight: column.implicitHeight + 12
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.bottom: 5
    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: root.visible = false
    }
    Column {
        id: column
        x: 6
        y: 6
        width: root.width - 12
        focus: true
        Keys.onEscapePressed: root.visible = false
        Keys.onLeftPressed: root.back()
        BarButton {
            visible: root.stack.length > 0
            width: column.width
            text: "‹ Back"
            onClicked: root.back()
        }
        Repeater {
            model: root.currentEntries
            BarButton {
                required property var modelData
                width: column.width
                text: modelData.label + (modelData.children ? "  ›" : "")
                onClicked: {
                    if (modelData.children) {
                        root.stack = root.stack.concat([root.currentEntries]);
                        root.currentEntries = modelData.children;
                    } else {
                        root.visible = false;
                        root.selected(modelData);
                        if (modelData.command) Services.run(modelData.command);
                    }
                }
            }
        }
    }
}
