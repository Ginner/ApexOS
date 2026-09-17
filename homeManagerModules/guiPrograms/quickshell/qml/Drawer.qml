import QtQuick

Item {
    id: root
    objectName: "drawer"
    default property alias contents: row.data
    property bool expanded: false
    implicitWidth: expanded ? row.implicitWidth : 0
    implicitHeight: Settings.height - 4
    clip: true
    visible: implicitWidth > 0
    Behavior on implicitWidth { NumberAnimation { duration: 250; easing.type: Easing.InOutCubic } }
    Row { id: row; spacing: 3 }
}
