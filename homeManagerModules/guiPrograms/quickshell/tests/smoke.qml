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
    Item {
        parent: bar.contentItem
        visible: false
        Hexagon { id: segmentShape; width: 250; height: 29 }
        Hexagon { id: workspaceShape; width: 28; height: 23; lineWidth: 1.3 }
        Workspaces {
            id: workspaceFixture
            focusedWorkspaceName: "10"
            workspaces: [
                {name: "10", active: true, urgent: false},
                {name: "2", active: false, urgent: false},
                {name: "1", active: true, urgent: false},
                {name: "9", active: false, urgent: false}
            ]
        }
        BarButton { id: iconFixture; icon: "󰕾"; text: "50%" }
    }
    // Deliberately unanchored; visible popup interactions run in menu.qml offscreen.
    BarMenu { id: menuFixture; entries: [{label: "Example"}] }
    function check(condition, message) {
        if (!condition) {
            console.error("FAIL:", message);
            Qt.exit(1);
            throw new Error(message);
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
            const liveWorkspaces = items.find(item => item.orderedWorkspaces !== undefined && item !== workspaceFixture);
            root.check(liveWorkspaces.focusedWorkspaceName !== ""
                && liveWorkspaces.orderedWorkspaces.some(w => w.name === liveWorkspaces.focusedWorkspaceName),
                "Hyprland focus resolves to a live workspace indicator");
            const clockButton = items.find(item => item.fullDate !== undefined);
            root.check(clockButton !== undefined, "clock instantiated");
            clockButton.clicked();
            root.check(clockButton.fullDate, "clock toggles full date");
            clockButton.clicked();
            root.check(!clockButton.fullDate, "clock toggles back");
            for (const item of items.filter(item => item.objectName === "drawer"))
                item.expanded = true;
            for (const shape of [segmentShape, workspaceShape]) {
                const angle = Math.atan2((shape.height - shape.lineWidth) / 2, shape.tip) * 180 / Math.PI;
                root.check(Math.abs(angle - 60) < 0.001, "hexagon side angle is 60 degrees");
            }
            root.check(workspaceFixture.orderedWorkspaces.map(w => w.name).join(",") === "1,2,9,10", "numeric workspace ordering");
            const indicators = workspaceFixture.children.filter(item => item.objectName === "workspace-indicator");
            const one = indicators.find(item => item.modelData.name === "1");
            const ten = indicators.find(item => item.modelData.name === "10");
            root.check(ten.displayName === "0" && ten.width === one.width, "workspace 10 uses a single-width zero");
            root.check(Qt.colorEqual(one.outlineColor, Settings.accent) && Qt.colorEqual(ten.outlineColor, Settings.accent), "both visible workspaces have accented outlines");
            root.check(Qt.colorEqual(one.digitColor, Settings.foreground) && Qt.colorEqual(ten.digitColor, Settings.accent), "only the focused digit is accented");
            workspaceFixture.focusedWorkspaceName = "1";
            root.check(Qt.colorEqual(one.digitColor, Settings.accent) && Qt.colorEqual(ten.digitColor, Settings.foreground), "digit colour follows focus changes");
            const labels = root.descendants(iconFixture).filter(item => item.font !== undefined);
            root.check(labels.some(item => item.text === "󰕾" && item.font.pixelSize === 20), "icons have independent larger sizing");
            root.check(labels.some(item => item.text === "50%" && item.font.pixelSize === 14), "text size remains unchanged");
            root.check(menuFixture.grabFocus, "menus request native outside-click dismissal");
            const closeButton = root.descendants(menuFixture.contentItem).find(item => item.text === "× Close" && item.clicked !== undefined);
            root.check(closeButton !== undefined, "menu has an explicit Close entry");
            console.log("PASS: theme, clock, drawers, hexagon geometry, workspace sorting/focus, icon sizing, and menu configuration");
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
