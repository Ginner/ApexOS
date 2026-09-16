import QtQuick
import Quickshell.Networking

BarButton {
    id: root
    text: Services.networkDevice ? (Services.wifi ? "" : "󰈀") : Networking.wifiEnabled ? "󰤫" : "󰤮"
    foreground: Services.networkDevice ? Settings.foreground : Settings.critical
    tooltip: menu.visible ? "" : !Services.networkDevice ? "Network disconnected" : [
        Services.network ? Services.network.name : Services.networkDevice.name,
        Services.wifi && Services.network ? "Strength: " + Math.round(Services.network.signalStrength * 100) + "%" : "",
        Services.wifi && Services.frequency ? "Frequency: " + Services.frequency : "",
        "↑ " + Services.rate(Services.networkRate ? Services.networkRate.up : null)
            + "   ↓ " + Services.rate(Services.networkRate ? Services.networkRate.down : null)
    ].filter(s => s.length).join("\n")
    onRightClicked: menu.open()
    BarMenu { id: menu; anchor.item: root; entries: Settings.data.networkMenu }
}
