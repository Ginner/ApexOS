import QtQuick
import Quickshell

Item {
    id: root
    property string text: ""
    property string icon: ""
    property string tooltip: ""
    property color foreground: Settings.foreground
    property real maximumWidth: 10000
    property bool interactive: true
    readonly property bool hovered: mouse.containsMouse
    signal clicked()
    signal rightClicked()
    signal scrolled(int direction)
    implicitHeight: Settings.height - 4
    readonly property real iconSpacing: icon !== "" && text !== "" ? 5 : 0
    implicitWidth: Math.min(iconLabel.implicitWidth + iconSpacing + label.implicitWidth + 14, maximumWidth)
    opacity: enabled ? 1 : 0.45

    Row {
        x: 7
        height: parent.height
        spacing: root.iconSpacing
        Text {
            id: iconLabel
            height: parent.height
            visible: root.icon !== ""
            text: root.icon
            textFormat: Text.PlainText
            font.family: Settings.data.fontFamily
            font.pixelSize: Math.min(Settings.data.iconSize, root.height)
            color: root.hovered && root.interactive ? Settings.accent : root.foreground
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            id: label
            height: parent.height
            width: Math.max(0, root.width - 14 - iconLabel.implicitWidth - root.iconSpacing)
            text: root.text
            textFormat: Text.PlainText
            font.family: Settings.data.fontFamily
            font.pixelSize: Settings.data.fontSize
            font.bold: true
            color: root.hovered && root.interactive ? Settings.accent : root.foreground
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: event => {
            if (!root.interactive) return;
            if (event.button === Qt.RightButton) root.rightClicked();
            else root.clicked();
        }
        onWheel: event => {
            if (root.interactive && event.angleDelta.y !== 0)
                root.scrolled(event.angleDelta.y > 0 ? 1 : -1);
        }
    }
    BarTooltip {
        anchor.item: root
        text: root.tooltip
        requested: root.hovered && root.tooltip.length > 0
    }
}
