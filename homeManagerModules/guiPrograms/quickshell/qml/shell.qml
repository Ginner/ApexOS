import QtQuick
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    id: root
    function matches(screen, output) {
        if (output === "") return true;
        if (output === screen.name) return true;
        const description = output.replace(/^desc:/, "");
        return Hyprland.monitors.values.some(m => m.name === screen.name && m.description === description);
    }
    readonly property var screens: {
        const available = Quickshell.screens;
        const docked = Settings.data.dockedOutput;
        if (docked !== null) {
            const preferred = available.filter(s => matches(s, docked));
            if (preferred.length) return preferred;
        }
        return available.filter(s => matches(s, Settings.data.output));
    }
    Variants {
        model: root.screens
        Bar { }
    }
}
