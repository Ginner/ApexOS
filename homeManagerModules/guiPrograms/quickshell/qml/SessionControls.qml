import QtQuick

Segment {
    id: root
    Item {
        width: 24
        height: Settings.height - 4
        Image {
            anchors.centerIn: parent
            width: Math.min(Settings.data.iconSize, parent.height)
            height: width
            source: "file://" + Settings.data.logo
            fillMode: Image.PreserveAspectFit
        }
    }
    Drawer {
        expanded: root.hovered
        BarButton { icon: ""; tooltip: "Shut down"; onClicked: Services.run(Settings.data.commands.poweroff) }
        BarButton { icon: "󰜉"; tooltip: "Reboot"; onClicked: Services.run(Settings.data.commands.reboot) }
        BarButton { icon: ""; tooltip: "Lock"; onClicked: Services.run(Settings.data.commands.lock) }
    }
}
