import QtQuick
import Quickshell.Services.UPower

BarButton {
    id: root
    readonly property var battery: Services.battery
    readonly property int percent: battery ? Math.round(battery.percentage * 100) : 0
    readonly property bool charging: battery && battery.state === UPowerDeviceState.Charging
    visible: !Settings.data.noBattery && battery && battery.ready && battery.isPresent
        && (Services.chargeControl || battery.state !== UPowerDeviceState.FullyCharged)
    icon: charging ? "󰂄" : ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂂", "󰁹"][Math.min(8, Math.floor(percent / 12))]
    text: percent + "%" + (charging ? " (" + Services.duration(battery.timeToFull) + ")" : "")
    foreground: Services.chargeError ? Settings.critical : Services.chargeControl && Services.chargeLimit === 100
        ? Settings.accent : charging ? Settings.foreground : percent <= 15 ? Settings.critical : percent <= 30 ? Settings.warning : Settings.foreground
    tooltip: menu.visible ? "" : (battery ? (charging ? "Time to full: " + Services.duration(battery.timeToFull)
        : battery.state === UPowerDeviceState.FullyCharged ? "Fully charged"
        : "Time remaining: " + Services.duration(battery.timeToEmpty)) : "")
        + (Services.chargeTooltip ? "\n" + Services.chargeTooltip : "")
    interactive: Services.chargeControl !== null && !Services.chargeBusy
    onClicked: menu.toggle()
    onRightClicked: menu.toggle()
    BarMenu {
        id: menu
        anchor.item: root
        entries: [
            {label: "Charge to 100%", full: true},
            {label: "Restore charge limits", full: false}
        ]
        onSelected: entry => Services.setFullCharge(entry.full)
    }
}
