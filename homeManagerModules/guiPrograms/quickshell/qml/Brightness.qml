import QtQuick

Row {
    id: root
    readonly property int brightness: Services.brightness
    visible: !Settings.data.noBattery && brightness >= 0
    BarButton {
        icon: root.brightness < 25 ? "󰃞" : root.brightness < 50 ? "󰃝" : root.brightness < 75 ? "󰃟" : "󰃠"
        tooltip: root.brightness + "%"
        onScrolled: direction => Services.setBrightness(root.brightness + direction * 2)
    }
    Drawer {
        expanded: hover.hovered || slider.pressed
        BarSlider {
            id: slider
            from: 5
            value: root.brightness || 5
            onMoved: Services.setBrightness(value)
        }
    }
    HoverHandler { id: hover }
}
