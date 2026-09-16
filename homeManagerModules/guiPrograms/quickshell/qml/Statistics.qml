import QtQuick

Row {
    function display(value, suffix) {
        return value === undefined || value === null ? "—" : value + suffix;
    }
    BarButton {
        icon: ""
        text: display(Services.stats.cpu, "%")
        tooltip: "CPU usage"
        foreground: Services.severity(Services.stats.cpu, 80, 90)
        interactive: false
    }
    BarButton {
        // Load average is a runnable-task count, not a percentage.
        icon: "󰖡"
        text: display(Services.stats.load, "")
        tooltip: "1-minute load average"
        interactive: false
    }
    BarButton {
        icon: ""
        text: display(Services.stats.memory, "G")
        foreground: Services.severity(Services.stats.memoryPercent, 80, 90)
        interactive: false
    }
    BarButton {
        icon: ""
        text: display(Services.stats.temperature, "°")
        tooltip: "CPU temperature"
        foreground: Services.severity(Services.stats.temperature, 80, 90)
        interactive: false
    }
}
