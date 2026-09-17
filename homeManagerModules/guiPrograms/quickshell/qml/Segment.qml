import QtQuick

Item {
    id: root
    default property alias contents: content.data
    property alias spacing: content.spacing
    readonly property bool hovered: hover.hovered
    implicitWidth: content.implicitWidth + height + 8
    implicitHeight: Settings.height
    Hexagon { anchors.fill: parent }
    Row {
        id: content
        anchors.centerIn: parent
        spacing: 3
    }
    HoverHandler { id: hover }
}
