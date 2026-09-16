// Offscreen popup interaction checks: no windows or focus changes on the desktop.
import QtQuick
import Quickshell

ShellRoot {
    id: root
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
    FloatingWindow {
        implicitWidth: 400
        implicitHeight: 300
        BarButton { id: button; text: "Menu" }
        BarMenu {
            id: menu
            anchor.item: button
            entries: [{label: "Submenu", children: [{label: "Example"}]}]
        }
    }
    Timer {
        property int step: 0
        interval: 250
        repeat: true
        running: true
        onTriggered: {
            switch (step++) {
            case 0:
                menu.toggle();
                break;
            case 1:
                root.check(menu.visible, "toggle opens anchored popup");
                menu.toggle();
                break;
            case 2:
                root.check(!menu.visible, "toggle closes popup");
                menu.open();
                break;
            case 3: {
                root.check(menu.visible, "popup reopens");
                const close = root.descendants(menu.contentItem).find(item => item.text === "× Close" && item.clicked !== undefined);
                root.check(close !== undefined, "Close entry exists");
                close.clicked();
                break;
            }
            case 4:
                root.check(!menu.visible, "Close entry dismisses popup");
                menu.open();
                break;
            case 5: {
                const submenu = root.descendants(menu.contentItem).find(item => item.text === "Submenu  ›" && item.clicked !== undefined);
                root.check(submenu !== undefined, "submenu entry exists");
                submenu.clicked();
                root.check(menu.stack.length === 1, "submenu opens");
                menu.back();
                root.check(menu.stack.length === 0 && menu.visible, "Back returns to top-level menu");
                menu.back();
                break;
            }
            case 6:
                root.check(!menu.visible, "Back at top level closes menu");
                console.log("PASS: popup toggle, reopen, Close entry, and submenu Back");
                Qt.quit();
            }
        }
    }
}
