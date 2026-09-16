import QtQuick

Segment {
    id: root
    Item {
        width: 24
        height: Settings.height - 4
        Image {
            anchors.centerIn: parent
            width: 18
            height: 18
            source: "file://" + Settings.data.logo
            fillMode: Image.PreserveAspectFit
        }
    }
    Drawer {
        expanded: root.hovered
        BarButton { text: ""; tooltip: "Shut down"; onClicked: Services.run(Settings.data.commands.poweroff) }
        BarButton { text: "󰜉"; tooltip: "Reboot"; onClicked: Services.run(Settings.data.commands.reboot) }
        BarButton { text: ""; tooltip: "Lock"; onClicked: Services.run(Settings.data.commands.lock) }
    }
}
