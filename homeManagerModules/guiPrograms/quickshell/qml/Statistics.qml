import QtQuick
import Quickshell

Row {
    id: root
    property bool expanded: false
    readonly property bool previewRequested: !expanded && (info.hovered || previewHover.hovered)
    readonly property var measurements: [
        { icon: "", label: "CPU usage", value: display(Services.stats.cpu, "%"),
            color: Services.severity(Services.stats.cpu, 80, 90) },
        { icon: "", label: "Memory", value: display(Services.stats.memory, "G"),
            color: Services.severity(Services.stats.memoryPercent, 80, 90) },
        { icon: "󰋊", label: "Disk (/)", value: display(Services.stats.disk?.percent, "%"),
            detail: Services.stats.disk ? Services.stats.disk.used + " / " + Services.stats.disk.total + " GiB" : "—",
            color: Services.severity(Services.stats.disk?.percent, 80, 90) },
        { icon: "", label: "CPU temperature", value: display(Services.stats.temperature, "°"),
            color: Services.severity(Services.stats.temperature, 80, 90) }
    ]

    function display(value, suffix) {
        return value === undefined || value === null ? "—" : value + suffix;
    }
    onPreviewRequestedChanged: {
        if (previewRequested) {
            closeDelay.stop();
            if (!preview.visible) openDelay.restart();
        } else {
            openDelay.stop();
            closeDelay.restart();
        }
    }
    onExpandedChanged: {
        openDelay.stop();
        closeDelay.stop();
        preview.visible = false;
    }
    BarButton {
        id: info
        objectName: "statistics-info"
        icon: "󰙎"
        foreground: root.expanded ? Settings.accent : Settings.foreground
        onClicked: root.expanded = !root.expanded
    }
    Row {
        objectName: "statistics-inline"
        visible: root.expanded
        Repeater {
            model: root.measurements
            BarButton {
                required property var modelData
                icon: modelData.icon
                text: modelData.value
                tooltip: modelData.label + (modelData.detail ? ": " + modelData.detail : "")
                foreground: modelData.color
                interactive: false
            }
        }
    }
    Timer {
        id: openDelay
        interval: 300
        onTriggered: if (root.previewRequested) preview.visible = true
    }
    Timer {
        id: closeDelay
        // Allow the pointer to cross the gap between the bar and popup.
        interval: 200
        onTriggered: if (!root.previewRequested) preview.visible = false
    }
    PopupWindow {
        id: preview
        objectName: "statistics-preview"
        visible: false
        color: "transparent"
        anchor.item: info
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.bottom: 5
        implicitWidth: column.implicitWidth + 24
        implicitHeight: column.implicitHeight + 16
        Rectangle {
            anchors.fill: parent
            color: Settings.background
            border.color: Settings.muted
            HoverHandler { id: previewHover }
            Column {
                id: column
                x: 12
                y: 8
                spacing: 6
                Repeater {
                    model: root.measurements
                    Row {
                        required property var modelData
                        spacing: 8
                        Text {
                            width: Settings.data.iconSize + 4
                            text: modelData.icon
                            color: modelData.color
                            font.family: Settings.data.fontFamily
                            font.pixelSize: Settings.data.iconSize
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label + ": " + modelData.value
                                + (modelData.detail ? " (" + modelData.detail + ")" : "")
                            textFormat: Text.PlainText
                            color: modelData.color
                            font.family: Settings.data.fontFamily
                            font.pixelSize: Settings.data.fontSize
                        }
                    }
                }
            }
        }
    }
}
