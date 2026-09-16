// Run as shell.qml in a COPY of the generated configuration. This connects to
// the session for read-only service checks, but never maps a panel or invokes
// any system, media, network, or audio actions.
import QtQuick
import Quickshell
import Quickshell.WindowManager

ShellRoot {
    id: root
    Production { id: production }
    Bar {
        id: bar
        modelData: Quickshell.screens[0]
        implicitWidth: 2560
        visible: false
    }
    function check(condition, message) {
        if (!condition) {
            console.error("FAIL:", message);
            Qt.exit(1);
        }
    }
    function descendants(item) {
        let result = [item];
        for (const child of item.children || []) result = result.concat(descendants(child));
        return result;
    }
    Timer {
        interval: 1000
        running: true
        onTriggered: {
            root.check(Settings.background !== Settings.foreground, "theme colours must be distinct");
            root.check(!bar.visible, "smoke panel must stay hidden");
            root.check(production.screens.length > 0, "configured output selection resolves");
            const items = root.descendants(bar.contentItem);
            const clockButton = items.find(item => item.fullDate !== undefined);
            root.check(clockButton !== undefined, "clock instantiated");
            clockButton.clicked();
            root.check(clockButton.fullDate, "clock toggles full date");
            clockButton.clicked();
            root.check(!clockButton.fullDate, "clock toggles back");
            for (const item of items.filter(item => item.objectName === "drawer"))
                item.expanded = true;
            console.log("PASS: theme, clock toggle, and drawer expansion");
        }
    }
    Timer {
        interval: 11000
        running: true
        onTriggered: {
            root.check(typeof Services.stats.cpu === "number", "CPU delta sample received");
            root.check(typeof Services.stats.memory === "number", "memory sample received");
            root.check(typeof Services.stats.network === "object", "network counters received");
            root.check(!Services.awake, "no inhibitor started by smoke check");
            const items = root.descendants(bar.contentItem);
            const left = items.find(item => item.objectName === "left-group");
            const clock = items.find(item => item.objectName === "clock-group");
            const right = items.find(item => item.objectName === "right-group");
            root.check(left.width > 0 && right.width > 0 && clock.width > 0, "segments have content");
            root.check(left.x + left.width < clock.x, "left group does not overlap clock");
            root.check(clock.x + clock.width < right.x, "right group does not overlap clock");
            console.log("PASS: telemetry; workspace count:", WindowManager.windowsets.length,
                "audio available:", Services.audio !== null);
            Qt.quit();
        }
    }
}
