# AGENTS.md — homeManagerModules/guiPrograms/

GUI programs requiring a Wayland compositor. All modules here assume Hyprland as the compositor unless noted.

## What qualifies as a GUI program here

- Requires a running Wayland compositor to function
- Or: is a desktop component (status bar, screen locker, launcher, notification daemon)
- Or: requires GPU/display for rendering (image/video viewers)

## Current modules

| File | Option path | Description |
|---|---|---|
| firefox.nix | `myHomeModules.guiPrograms.firefox` | Firefox browser |
| hyprland.nix | `myHomeModules.guiPrograms.hyprland` | Hyprland compositor + hyprlock + hypridle |
| inkscape.nix | `myHomeModules.guiPrograms.inkscape` | Vector graphics editor |
| kde-connect.nix | `myHomeModules.guiPrograms.kde-connect` | KDE Connect HM-side config |
| mpv.nix | `myHomeModules.guiPrograms.mpv` | Video player |
| quickshell/ | `myHomeModules.guiPrograms.quickshell` | Default desktop/laptop status bar; see its README for migration and controls |
| swayimg.nix | `myHomeModules.guiPrograms.swayimg` | Image viewer (Wayland-native) |
| walker.nix | `myHomeModules.guiPrograms.walker` | Application launcher |
| zathura.nix | `myHomeModules.guiPrograms.zathura` | PDF/document viewer |

## Wayland/Hyprland-specific conventions

- All GUI modules assume Wayland. X11 compatibility is not a goal.
- Programs that interact with the clipboard use `wl-clipboard` (provided by `cliPrograms/wayland-tools.nix`).
- Screenshot tools: `grim` + `slurp` (also in wayland-tools).
- `hyprland.nix` contains the full Hyprland config including `hyprlock` (screen locker) and `hypridle` (idle management).

## hyprland.nix details

This is the largest and most complex HM module. It contains:
- `wayland.windowManager.hyprland` settings: gaps, borders, input (dk keyboard layout, TrackPoint settings), keybindings, startup exec
- `programs.hyprlock` configuration (screenshot background blur, input field)
- `services.hypridle` configuration (brightness dim → lock → DPMS off → suspend chain)

**Known issue**: Device-specific input settings (TrackPoint sensitivity, touchpad disable) are hardcoded in this module with a TODO comment noting they should be in host configs. These BISHOP-specific settings will apply to any host using this module.

**startupPrograms option**: exposes `startupPrograms` (list of strings, default `["swaync"]`), wired through to the startup script. Quickshell is started separately by its systemd user service, tied to `hyprland-session.target`.

## Stylix theming

There is no HM-level stylix module. `stylix.nixosModules.stylix` (in `flake.nix`) handles all theming via `stylix.homeManagerIntegration.autoImport = true` (the default), which automatically propagates the NixOS theme (scheme, fonts, cursor, image) to all HM-managed programs.

Active theme defaults (set in `nixosModules/shared/stylix.nix`):
- Colour scheme: `google-dark` (base16)
- Monospace font: `Hack Nerd Font Mono` (`nerd-fonts.hack`)
- Cursor: `rose-pine-hyprcursor`

Per-host wallpaper is set directly in `hosts/<HOSTNAME>/home.nix`:
```nix
stylix.image = ../../assets/wall.jpeg;
```

## quickshell/ (directory)

- `default.nix` defines options, dependencies, generated `Settings.qml`, and the
  Home Manager/systemd integration.
- `qml/` contains reusable pointed segments, widgets, menus, and shared services.
- `monitor.py` provides read-only CPU/memory/temperature/network telemetry.
- `tests/` contains telemetry tests and isolated QML smoke/menu configurations.
- `README.md` documents options, controls, and consumer migration.

Both bundles enable `myHomeModules.guiPrograms.quickshell` with `mkDefault true`.
The desktop bundle defaults to `noBattery = true` and `output = ""` (all outputs).
Laptop defaults include battery/brightness controls and `output = "eDP-1"`.
`dockedOutput` is preferred automatically when present; Kanshi only owns monitor
layout and should not start or restart the bar.

The layout uses elongated hexagonal segments, a centred clock without a calendar,
workspace/media controls, status indicators, drawers, and context menus. Visible
workspaces have accented outlines; only the focused workspace's digit is accented.

Stylix colours and font settings are generated into `Settings.qml`. Status icons
use Nerd Font glyphs with an independent `iconSize` option. The service includes
the generated config path in its environment so Home Manager restarts it on
configuration changes, while keeping the stable `--config apex` shell identity.

## MIME associations

MIME defaults are set in `homeManagerModules/services/xdg.nix`, not in individual program modules:
- `text/*` → nvim
- `application/pdf` → zathura
- `image/*` → swayimg
- `video/*` → mpv

## Adding a new GUI program module

See `skills/new-home-module.md`.
