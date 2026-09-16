import QtQuick
import QtQuick.Controls

Slider {
    id: root
    from: 0
    to: 100
    stepSize: 1
    implicitWidth: 75
    implicitHeight: Settings.height - 4
    padding: 5
    background: Rectangle {
        x: root.leftPadding
        y: (root.height - height) / 2
        width: root.availableWidth
        height: 4
        color: Settings.muted
        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            color: Settings.foreground
        }
    }
    handle: Hexagon {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: (root.height - height) / 2
        width: 9
        height: 10
        fillColor: root.pressed ? Settings.accent : Settings.foreground
    }
}
