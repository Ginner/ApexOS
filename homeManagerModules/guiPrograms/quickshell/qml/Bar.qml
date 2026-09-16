import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    required property var modelData
    screen: modelData
    anchors { top: true; left: true; right: true }
    margins { top: 5; left: 4; right: 4; bottom: 5 }
    implicitHeight: Settings.height
    color: "transparent"
    WlrLayershell.namespace: "apex-bar"
    WlrLayershell.layer: WlrLayer.Top
    // Keep the transparent spaces between segments click-through.
    mask: Region {
        item: left
        Region { item: clock }
        Region { item: right }
    }
    Row {
        id: left
        objectName: "left-group"
        anchors.left: parent.left
        spacing: 8
        SessionControls { id: session }
        Segment {
            Workspaces { id: workspaces }
            Media {
                availableWidth: Math.min(390, Math.max(0, clock.x - left.x - session.width
                    - workspaces.width - Settings.height - 35))
            }
        }
    }
    Clock { id: clock; objectName: "clock-group"; anchors.centerIn: parent }
    Row {
        id: right
        objectName: "right-group"
        anchors.right: parent.right
        spacing: 8
        Segment {
            Audio { }
            Brightness { }
            Awake { }
            Statistics { }
            BluetoothStatus { }
            NetworkStatus { }
            Battery { }
        }
        ControlCenter { }
    }
}
