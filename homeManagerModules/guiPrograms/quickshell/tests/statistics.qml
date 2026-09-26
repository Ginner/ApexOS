import QtQuick
import QtTest
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
    FloatingWindow {
        id: window
        implicitWidth: 800
        implicitHeight: 300
        Statistics { id: statistics }
        TestCase { id: pointer; when: false }
    }
    Timer {
        property int step: 0
        property real collapsedWidth: 0
        property var info: statistics.children.find(item => item.objectName === "statistics-info")
        property var inlineRow: statistics.children.find(item => item.objectName === "statistics-inline")
        property var preview: statistics.resources.find(item => item.objectName === "statistics-preview")
        interval: 400
        repeat: true
        running: true
        onTriggered: {
            switch (step++) {
            case 0:
                root.check(!statistics.expanded && !inlineRow.visible, "collapsed by default");
                root.check(info.icon.codePointAt(0) === 0xf064e, "requested info glyph");
                root.check(statistics.measurements.length === 4, "four measurements, no load average");
                root.check(statistics.measurements[2].icon.codePointAt(0) === 0xf02ca, "disk between memory and temperature");
                collapsedWidth = statistics.width;
                info.clicked();
                break;
            case 1:
                root.check(statistics.expanded && inlineRow.visible, "click expands measurements");
                root.check(info.visible && statistics.width > collapsedWidth, "info remains visible and bar grows");
                Services.stats = ({});
                break;
            case 2:
                root.check(statistics.measurements.every(item => item.value === "—"), "missing data shown as unavailable");
                info.clicked();
                break;
            case 3:
                root.check(!statistics.expanded && !inlineRow.visible, "second click collapses measurements");
                root.check(statistics.width === collapsedWidth, "collapsed width restored");
                pointer.mouseMove(info, info.width / 2, info.height / 2);
                break;
            case 4:
                root.check(preview.visible, "hover opens dropdown");
                info.clicked();
                break;
            case 5:
                root.check(statistics.expanded && !preview.visible, "expansion dismisses hover dropdown");
                pointer.mouseMove(window.contentItem, 700, 200);
                info.clicked();
                break;
            case 6:
                pointer.mouseMove(info, info.width / 2, info.height / 2);
                break;
            case 7:
                root.check(preview.visible, "hover reopens after collapsing");
                pointer.mouseMove(window.contentItem, 700, 200);
                break;
            case 8:
                root.check(!preview.visible, "leaving dismisses dropdown");
                console.log("PASS: statistics defaults, glyphs, order, expansion, missing data, collapse, and hover transitions");
                Qt.quit();
            }
        }
    }
}
