# ApexOS Quickshell bar

Opt-in replacement for the Waybar module, using Quickshell 0.3.1 or newer.
Desktop/laptop bundles still default to Waybar during the initial rollout.

```nix
myHomeModules.guiPrograms.waybar.enable = false;
myHomeModules.guiPrograms.quickshell = {
  enable = true;
  output = "DP-1"; # Or "desc:Make Model Serial"; empty means every output.
  noBattery = true;
};
```

The `quickshell.service` user unit starts with `hyprland-session.target` and
stops with that session. Do not also add Quickshell to Hyprland startupPrograms.
The generated configuration is installed at `~/.config/quickshell/apex/`.

## Appearance and controls

- Elongated hexagonal segments with 60-degree sides (120-degree interior
  angles), using Stylix colours and fonts.
- Flat-top/bottom workspace hexagons: outlines use the theme accent for every
  visible workspace, but only the focused workspace's number is accented.
  Numeric workspaces are sorted numerically; workspace 10 is labelled `0`.
  Click to activate, scroll to cycle workspaces.
- Hover the logo to reveal shutdown, reboot, and lock.
- Click media to play/pause; scroll up/down for previous/next. The displayed
  player and commands share the same MPRIS object, preferring playerctld.
- Hover volume/brightness to reveal their sliders; scroll changes them by 2%.
  Click volume to toggle mute, right-click for audio settings.
- Click the awake icon for indefinite idle/sleep inhibition; right-click for
  15/30/60/120-minute timers or to turn it off. The inhibitor is owned by the
  shell and is released when the shell exits. It is not restored after restart.
- Right-click networking for Wi-Fi and connection tools, or Bluetooth for Blueman.
- Click the clock to toggle full date/time. There is no calendar popup.
- Click `[C]` to toggle SwayNC; right-click for system and theme tools.
- Menus use native popup grabs to close on an outside click or Escape. They
  also provide a Close entry (or Back inside a submenu); right-clicking a menu
  button toggles its popup.

CPU, memory, load, temperature, brightness, and network counters are sampled by
one read-only helper every five seconds. Missing hardware/data is shown as
unavailable or hidden rather than as a fabricated zero. Load is a task count,
memory is GiB, and network rates use binary units. CPU usage and network rates
need two samples. Temperature defaults to the hottest CPU sensor, falling back
to thermal zones; `temperaturePath` selects an explicit runtime sysfs path.

## Laptop and docking configuration

Leave `noBattery = false` for battery and brightness widgets. `backlightDevice`
can select a specific `/sys/class/backlight` device; empty auto-detects one.
`dockedOutput` accepts a connector or monitor description, preferring it whenever
available and automatically returning to `output` when disconnected. Kanshi
continues to own the monitor layout, but old profile commands that kill/start
Waybar must be removed in the consuming host before migrating a laptop.

`refreshRateActions` supplies host-specific context-menu entries:

```nix
myHomeModules.guiPrograms.quickshell.refreshRateActions = [
  { label = "Preferred settings"; command = [ "hyprctl" "reload" ]; }
];
```

`height` (29 logical pixels by default), `fontSize` (14), `iconSize` (20), `fontFamily` (Stylix
monospace), and `logo` are also configurable. Use a Nerd Font for status glyphs.
Icon sizing is independent of labels and menu text, and is capped to fit the bar.

## Verification and rollout

Build/evaluate from the consuming host flake with a local ApexOS override while
the module is uncommitted. Use `path:/absolute/path/to/ApexOS/repo` so new files
are included, and `--no-write-lock-file` to preserve the remote pins. A host
using a private user input may also need a local override for that input.

Build `nixosConfigurations.<HOST>.config.home-manager.users.<USER>.programs.quickshell.configs.apex`
to check the generated shell independently of a full system build. Validate
QML loading and then check interactions in a real Hyprland session; a successful
Nix build alone does not validate QML behaviour.

`tests/test_monitor.py` exercises CPU/memory calculations, missing sensors,
first samples, and reset network counters using the Nix-provided Python.
`tests/smoke.nix` is a function accepting the generated shell derivation. It
creates a separate shell with hidden panels and a timed smoke test of theme
values, output selection, clock toggling, drawer expansion, layout, and live
read-only telemetry. Build its `drvPath` using `nix eval --raw --impure` with
`--apply 'shell: (import /absolute/path/to/quickshell/tests/smoke.nix shell).drvPath'`,
then `nix build --no-link --print-out-paths "$drv^*"` and run Quickshell with
`--path` pointing to that output. This test requires a running Hyprland session;
it does not map a panel or invoke system/media/audio/network actions.

The smoke test also covers 60-degree segment geometry, numeric workspace order,
the `10` → `0` label, visible-versus-focused colours, and separate icon sizing.
`tests/menu.nix` accepts the same shell derivation and provides an additional
popup interaction test. Run that output with `QT_QPA_PLATFORM=offscreen` and
`QT_QUICK_BACKEND=software` to test toggling, reopening, Close, and submenu Back
without showing windows on the desktop. Compositor-driven outside-click and
keyboard dismissal should also be checked during a live trial.

After explicit activation, inspect:

```sh
systemctl --user status quickshell.service
journalctl --user -u quickshell.service -b
```

WOPR is the first rollout. Laptop battery/backlight behaviour, docking, and
other monitor scales need hardware validation before changing bundle defaults.
To revert, disable this module and re-enable Waybar in the host, then rebuild.
Unactivated WOPR host changes depend on the new ApexOS module: use the local
override until the ApexOS input has been updated to a revision containing it.
