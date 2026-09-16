# ApexOS Quickshell bar

The default ApexOS desktop/laptop status bar, using Quickshell 0.3.1 or newer.
Both bundles enable it with `lib.mkDefault true`, so a host can override it.
Desktop defaults hide battery/brightness widgets and show the bar on all outputs;
laptop defaults include those widgets and select `eDP-1`.

```nix
myHomeModules.guiPrograms.quickshell = {
  enable = true; # Already enabled by the desktop and laptop bundles.
  output = "DP-1"; # Or "desc:Make Model Serial"; empty means every output.
  noBattery = true;
};
```

The `quickshell.service` user unit starts with `hyprland-session.target` and
stops with that session. Do not also add Quickshell to Hyprland startupPrograms.
The generated configuration is installed at `~/.config/quickshell/apex/`.
The service's `APEX_QUICKSHELL_CONFIG` environment entry references that
configuration's store path. Configuration changes therefore change the unit and
trigger a restart during Home Manager activation with service switching enabled.
This avoids relying on a file watcher noticing a replaced configuration symlink,
while preserving the stable `--config apex` shell identity. Restarting the bar
also resets its stay-awake toggle/timer.

## Migrating from Waybar

The ApexOS Waybar module and `myHomeModules.guiPrograms.waybar` options have been
removed. In consuming host/user flakes:

1. Move `output`, `dockedOutput`, `noBattery`, and `logo` settings from
   `myHomeModules.guiPrograms.waybar` to `myHomeModules.guiPrograms.quickshell`.
2. Remove old `waybar.enable = false` settings used during the Quickshell trial.
   To intentionally run without a bar, set the new `quickshell.enable = false`.
3. Remove host-specific `programs.waybar`/`stylix.targets.waybar` customizations
   and explicit Waybar packages or Hyprland startup entries.
4. Remove Kanshi profile commands that kill or start Waybar or select its
   `config-undocked.json`/`config-docked.json`. Keep the monitor profiles;
   Quickshell uses `output`/`dockedOutput` to follow their resulting layout.

Home Manager removes the old managed bar configuration links on activation.
The legacy module is no longer an in-tree fallback; use an earlier system
generation if you need to roll back the migration.

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
continues to own the monitor layout; bar lifecycle is handled by the user service.

`refreshRateActions` supplies host-specific context-menu entries:

```nix
myHomeModules.guiPrograms.quickshell.refreshRateActions = [
  { label = "Preferred settings"; command = [ "hyprctl" "reload" ]; }
];
```

`height` (29 logical pixels by default), `fontSize` (14), `iconSize` (20), `fontFamily` (Stylix
monospace), and `logo` are also configurable. Use a Nerd Font for status glyphs.
Icon sizing is independent of labels and menu text, and is capped to fit the bar.

## Verification

Build/evaluate from the consuming host flake with a local ApexOS override while
the module is uncommitted. Use `path:/absolute/path/to/ApexOS/repo` so new files
are included, and `--no-write-lock-file` to preserve the remote pins. A host
using a private user input may also need a local override for that input.

Build `nixosConfigurations.<HOST>.config.home-manager.users.<USER>.programs.quickshell.configs.apex`
to check the generated shell independently of a full system build. Validate
QML loading and then check interactions in a real Hyprland session; a successful
Nix build alone does not validate QML behaviour.

`tests/integration.nix` accepts a consuming `nixosConfigurations.<HOST>` from
`mkHost`. Evaluate it with `nix eval --json --impure` and
`--apply 'system: import /absolute/path/to/quickshell/tests/integration.nix system'`.
It checks desktop/laptop defaults, removal of the legacy bar, and that a config
change changes the service unit while preserving the shell command/identity.

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

Battery/backlight behaviour, docking, and other monitor scales need validation
on the relevant hardware. When testing local changes, use the local override
until the consuming flake's ApexOS input points to the desired revision.
