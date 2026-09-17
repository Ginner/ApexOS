import QtQuick

BarButton {
    id: root
    icon: Services.awake ? "󰅶" : "󰛊"
    foreground: Services.awake ? Settings.accent : Settings.foreground
    tooltip: menu.visible ? "" : Services.awakeTooltip
    onClicked: Services.toggleAwake()
    onRightClicked: menu.toggle()
    BarMenu {
        id: menu
        anchor.item: root
        entries: [
            {label: "Stay awake for 15 minutes", seconds: 900},
            {label: "Stay awake for 30 minutes", seconds: 1800},
            {label: "Stay awake for 1 hour", seconds: 3600},
            {label: "Stay awake for 2 hours", seconds: 7200},
            {label: "Turn off", seconds: -1}
        ]
        onSelected: entry => {
            if (entry.seconds < 0) Services.stopAwake();
            else Services.startAwake(entry.seconds);
        }
    }
}
