import QtQuick
import Quickshell

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
    function toggle() {
        if (visible) visible = false;
        else open();
    }
    function back() {
        if (stack.length === 0) { visible = false; return; }
        const previous = stack.slice();
        currentEntries = previous.pop();
        stack = previous;
    }
    visible: false
    // Use the xdg-popup grab: the compositor dismisses this on outside clicks.
    grabFocus: true
    onVisibleChanged: if (visible) Qt.callLater(() => { if (root.visible) column.forceActiveFocus(); })
    color: Settings.background
    implicitWidth: 245
    implicitHeight: column.implicitHeight + 12
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.bottom: 5
    Column {
        id: column
        x: 6
        y: 6
        width: root.width - 12
        focus: true
        Keys.onEscapePressed: root.visible = false
        Keys.onLeftPressed: root.back()
        BarButton {
            width: column.width
            text: root.stack.length > 0 ? "‹ Back" : "× Close"
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
