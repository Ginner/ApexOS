import QtQuick

Row {
    id: root
    readonly property var audio: Services.audio
    readonly property bool expanded: hover.hovered || slider.pressed
    BarButton {
        icon: !root.audio || root.audio.muted ? "󰝟" : root.audio.volume < 0.33 ? "󰕿" : root.audio.volume < 0.66 ? "󰖀" : "󰕾"
        tooltip: root.audio ? Math.round(root.audio.volume * 100) + "%" + (root.audio.muted ? " (muted)" : "") : "No audio output"
        onClicked: if (root.audio) root.audio.muted = !root.audio.muted
        onRightClicked: Services.run(Settings.data.commands.audioSettings)
        onScrolled: direction => { if (root.audio) Services.setVolume(root.audio.volume * 100 + direction * 2); }
    }
    Drawer {
        expanded: root.expanded
        BarSlider {
            id: slider
            enabled: root.audio !== null
            value: root.audio ? root.audio.volume * 100 : 0
            onMoved: Services.setVolume(value)
        }
    }
    HoverHandler { id: hover }
}
