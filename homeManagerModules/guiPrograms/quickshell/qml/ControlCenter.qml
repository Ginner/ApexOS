import QtQuick

Segment {
    BarButton {
        id: button
        text: "[C]"
        foreground: Settings.accent
        onClicked: Services.run(Settings.data.commands.notifications)
        onRightClicked: menu.open()
        BarMenu { id: menu; anchor.item: button; entries: Settings.data.controlMenu }
    }
}
