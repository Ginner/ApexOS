import QtQuick

BarButton {
    maximumWidth: 160
    icon: Services.bluetoothDevices.length ? "" : Services.bluetoothEnabled ? "󰂰" : "󰂲"
    text: Services.bluetoothDevices.map(d => d.name).join(", ")
    tooltip: Services.bluetoothDevices.length ? Services.bluetoothDevices.map(d =>
        d.name + (d.batteryAvailable ? "   " + Math.round(d.battery * 100) + "%" : "")).join("\n")
        : Services.bluetoothEnabled ? "Bluetooth on" : "Bluetooth off"
    onRightClicked: Services.run(Settings.data.commands.bluetoothSettings)
}
