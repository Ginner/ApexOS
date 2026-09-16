import QtQuick
import Quickshell.Services.UPower

BarButton {
    readonly property var battery: Services.battery
    readonly property int percent: battery ? Math.round(battery.percentage * 100) : 0
    readonly property bool charging: battery && battery.state === UPowerDeviceState.Charging
    visible: !Settings.data.noBattery && battery && battery.ready && battery.isPresent
        && battery.state !== UPowerDeviceState.FullyCharged
    icon: charging ? "󰂄" : ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂂", "󰁹"][Math.min(8, Math.floor(percent / 12))]
    text: percent + "%" + (charging ? " (" + Services.duration(battery.timeToFull) + ")" : "")
    foreground: charging ? Settings.foreground : percent <= 15 ? Settings.critical : percent <= 30 ? Settings.warning : Settings.foreground
    tooltip: battery ? (charging ? "Time to full: " + Services.duration(battery.timeToFull)
        : "Time remaining: " + Services.duration(battery.timeToEmpty)) : ""
    interactive: false
}
