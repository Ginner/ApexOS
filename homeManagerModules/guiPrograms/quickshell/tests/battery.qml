import QtQuick
import Quickshell

ShellRoot {
    id: root
    property var menu
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
    function select(label) {
        const entry = descendants(menu.contentItem).find(item => item.text === label && item.clicked !== undefined);
        check(entry !== undefined, "menu contains " + label);
        entry.clicked();
    }
    FloatingWindow {
        implicitWidth: 400
        implicitHeight: 300
        Battery { id: battery }
    }
    Timer {
        property int step: 0
        interval: 250
        repeat: true
        running: true
        onTriggered: {
            switch (step++) {
            case 0:
                root.check(battery.visible, "fully charged battery remains accessible");
                root.menu = Array.from(battery.data).find(item => item.entries !== undefined);
                root.check(root.menu !== undefined, "battery menu exists");
                Services.stats = ({chargeLimit: 80});
                battery.clicked();
                break;
            case 1:
                root.check(root.menu.visible, "battery click opens menu");
                root.select("Charge to 100%");
                break;
            case 2:
                root.check(!Services.chargeBusy && Services.chargeError === "", "fullcharge command succeeds");
                root.check(Services.chargeLimit === 80, "success does not invent hardware state");
                Services.stats = ({chargeLimit: 100});
                root.check(battery.foreground.toString() === Settings.accent.toString(), "100% limit accented");
                battery.clicked();
                break;
            case 3:
                root.select("Restore charge limits");
                break;
            case 4:
                root.check(Services.chargeError.includes("fixture restore failure"), "failure visible");
                root.check(Services.chargeLimit === 100, "failure preserves observed state");
                root.check(battery.foreground.toString() === Settings.critical.toString(), "failure highlighted");
                Services.chargeError = "";
                Services.stats = ({});
                root.check(battery.tooltip.includes("unavailable"), "missing threshold labelled unavailable");
                root.check(battery.interactive, "restore remains available without threshold reporting");
                console.log("PASS: battery menu, full-charge command, restore failure, hardware state and full battery visibility");
                Qt.quit();
            }
        }
    }
}
