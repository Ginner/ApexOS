pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Singleton {
    id: root
    property var stats: ({})
    readonly property var players: Mpris.players.values
    // playerctld keeps the displayed metadata and commands on the most recently active player.
    readonly property var player: players.find(p => p.dbusName === "org.mpris.MediaPlayer2.playerctld")
        || players.find(p => p.isPlaying) || players[0] || null
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink && sink.ready ? sink.audio : null
    readonly property var battery: Settings.data.noBattery ? null : UPower.displayDevice
    readonly property var bluetoothDevices: Bluetooth.devices.values.filter(d => d.connected)
    readonly property bool bluetoothEnabled: Bluetooth.adapters.values.some(a => a.enabled)
    readonly property var connectedDevices: Networking.devices.values.filter(d => d.connected)
    readonly property var networkDevice: connectedDevices.find(d => d.type === DeviceType.Wired)
        || connectedDevices[0] || null
    readonly property bool wifi: networkDevice !== null && networkDevice.type === DeviceType.Wifi
    readonly property var network: networkDevice ? networkDevice.networks.values.find(n => n.connected) || null : null
    readonly property var networkRate: networkDevice && stats.network ? stats.network[networkDevice.name] || null : null
    property string frequency: ""
    property bool awake: false
    property double awakeUntil: 0
    property string awakeError: ""
    readonly property string awakeTooltip: awakeError || (!awake ? "Idle and sleep inhibition off"
        : awakeUntil === 0 ? "Idle and sleep inhibition on"
        : "Idle and sleep inhibition on: " + Math.max(0, Math.ceil((awakeUntil - clock.date.getTime()) / 60000)) + " min remaining")
    readonly property date now: clock.date

    function run(command) {
        if (command && command.length) Quickshell.execDetached(command);
    }
    function setVolume(percent) {
        if (audio) audio.volume = Math.max(0, Math.min(100, percent)) / 100;
    }
    function setBrightness(percent) {
        brightnessTarget = Math.max(5, Math.min(100, Math.round(percent)));
        brightness = brightnessTarget;
        brightnessDebounce.restart();
    }
    function startAwake(seconds) {
        awakeError = "";
        awakeUntil = seconds > 0 ? Date.now() + seconds * 1000 : 0;
        awake = true;
    }
    function stopAwake() {
        awake = false;
        awakeUntil = 0;
        awakeError = "";
    }
    function toggleAwake() {
        if (awake) stopAwake();
        else startAwake(0);
    }
    function rate(value) {
        if (value === undefined || value === null) return "—";
        if (value < 1024) return value + " B/s";
        if (value < 1048576) return (value / 1024).toFixed(1) + " KiB/s";
        return (value / 1048576).toFixed(1) + " MiB/s";
    }
    function duration(seconds) {
        if (seconds <= 0) return "estimating";
        return Math.floor(seconds / 3600) + ":" + String(Math.floor(seconds % 3600 / 60)).padStart(2, "0");
    }
    function severity(value, warning, critical) {
        if (value === undefined || value === null) return Settings.muted;
        return value >= critical ? Settings.critical : value >= warning ? Settings.warning : Settings.foreground;
    }

    PwObjectTracker { objects: root.sink ? [root.sink] : [] }
    SystemClock { id: clock; precision: SystemClock.Seconds }
    Process {
        id: telemetry
        command: Settings.data.monitorCommand
        running: true
        stdout: SplitParser {
            onRead: data => {
                try { root.stats = JSON.parse(data); }
                catch (error) { console.warn("Invalid telemetry snapshot:", error.message); }
            }
        }
        onExited: {
            root.stats = ({});
            telemetryRestart.restart();
        }
    }
    Timer { id: telemetryRestart; interval: 5000; onTriggered: telemetry.running = true }

    // One process owns the logind inhibitor. Exiting the shell releases it too.
    Process {
        id: inhibitor
        command: Settings.data.inhibitCommand
        running: root.awake
        stderr: StdioCollector {
            onStreamFinished: if (text.trim()) root.awakeError = "Could not inhibit sleep: " + text.trim()
        }
        onExited: (exitCode, exitStatus) => {
            const unexpected = root.awake;
            root.awake = false;
            root.awakeUntil = 0;
            if (unexpected && exitCode !== 0 && root.awakeError === "")
                root.awakeError = "Sleep inhibitor exited; inhibition is off";
        }
    }
    Timer {
        interval: 1000
        repeat: true
        running: root.awake && root.awakeUntil > 0
        onTriggered: if (Date.now() >= root.awakeUntil) root.stopAwake()
    }

    property int brightness: -1
    property int brightnessTarget: 0
    onStatsChanged: {
        if (!brightnessProcess.running && !brightnessDebounce.running)
            brightness = stats.brightness ?? -1;
    }
    Timer {
        id: brightnessDebounce
        interval: 60
        onTriggered: {
            if (!brightnessProcess.running)
                brightnessProcess.exec(Settings.data.brightnessCommand.concat(["set", root.brightnessTarget + "%"]));
            else restart();
        }
    }
    Process {
        id: brightnessProcess
        onExited: (code, status) => {
            if (code !== 0) root.brightness = root.stats.brightness ?? -1;
        }
    }

    // Frequency is not currently exposed by Quickshell's WifiNetwork API.
    Process {
        id: wifiDetails
        command: [Settings.data.nmcli, "--terse", "--fields", "ACTIVE,FREQ", "device", "wifi", "list",
            "ifname", root.wifi ? root.networkDevice.name : "", "--rescan", "no"]
        environment: ({ LC_ALL: "C" })
        stdout: StdioCollector {
            onStreamFinished: {
                const active = text.split("\n").find(line => line.startsWith("yes:"));
                root.frequency = active ? active.substring(4).trim() : "";
            }
        }
    }
    Timer {
        interval: 10000
        running: root.wifi
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!wifiDetails.running) wifiDetails.running = true
    }
    onNetworkDeviceChanged: {
        frequency = "";
        if (wifi && !wifiDetails.running) wifiDetails.running = true;
    }
}
