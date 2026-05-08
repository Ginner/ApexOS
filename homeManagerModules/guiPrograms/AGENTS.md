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
| swayimg.nix | `myHomeModules.guiPrograms.swayimg` | Image viewer (Wayland-native) |
| walker.nix | `myHomeModules.guiPrograms.walker` | Application launcher |
| waybar/ | `myHomeModules.guiPrograms.waybar` | Status bar for Hyprland |
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

**startupPrograms option**: exposes `startupPrograms` (list of strings, default `["waybar" "swaync"]`), wired through to the startup script.

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

## waybar/ (directory)

The module lives under `waybar/` with the following files:

| File | Purpose |
|---|---|
| `default.nix` | Nix module — options, `programs.waybar` settings, `home.file` for XMLs |
| `style.css` | GTK CSS — read via `builtins.readFile` at eval time |
| `network.xml` | GTK Builder XML for the network context menu |
| `ctlcenter.xml` | GTK Builder XML for the control-center context menu |

Follows the standard `myHomeModules.guiPrograms.waybar.enable` pattern. The laptop bundle enables it with `mkDefault true`. Exposes an `output` option (default `"eDP-1"`) so hosts can override which monitor waybar is anchored to.

**Layout**: based on cebem1nt/dotfiles — expanding-drawer pills on both sides, a centered clock pill.  Left side: `custom/start` (Walker launcher) + expandable drawer (battery, cpu, load) + workspaces + window title.  Right side: bluetooth, volume/backlight sliders, network, tray + expandable drawer (memory, temperature) + `custom/ctlcenter` (swaync toggle).

**Stylix integration** is handled inside the module:
- `stylix.targets.waybar.enable = true` — injects `@base00`–`@base0F` CSS custom properties
- `stylix.targets.waybar.addCss = false` — suppresses Stylix's structural CSS overrides
- `style.css` maps `@baseXX` slots to semantic names (`@fg`, `@module-bg`, `@inactive`, `@red`, `@blue`, `@yellow`, `@green`) via `@define-color` at the top

**Nerd Font glyph notes**: codepoints in `format` and `format-icons` fields must be literal UTF-8 characters in the source — `\uXXXX` escapes do not work in Nix strings. Font is `Hack Nerd Font` (proportional); the CSS `*` selector overrides Stylix's prepended `Hack Nerd Font Mono`.

## MIME associations

MIME defaults are set in `homeManagerModules/services/xdg.nix`, not in individual program modules:
- `text/*` → nvim
- `application/pdf` → zathura
- `image/*` → swayimg
- `video/*` → mpv

## Adding a new GUI program module

See `skills/new-home-module.md`.
