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
| waybar.nix | `myHomeModules.guiPrograms.waybar` | Status bar for Hyprland |
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

**startupPrograms option**: exposes `startupPrograms` (list of strings, default `["waybar" "mako"]`), wired through to the startup script.

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

## waybar.nix

Follows the standard `myHomeModules.guiPrograms.waybar.enable` pattern. The laptop bundle enables it with `mkDefault true`. Exposes an `output` option (default `"eDP-1"`) so hosts can override which monitor waybar is anchored to.

Stylix integration is handled inside the module itself:
- `stylix.targets.waybar.enable = true` — injects `@base00`–`@base0F` CSS colour variables
- `stylix.targets.waybar.addCss = false` — suppresses Stylix's structural CSS overrides; layout is managed manually

The bar uses three floating pills (left/center/right) with arrow-glyph edge caps (`custom/sep-*` modules) to create pointed edges. Font is `Hack Nerd Font` (already installed by `nixosModules/shared/stylix.nix`). The left pill's logo module opens a GTK power menu; its XML is written to `~/.config/waybar/power_menu.xml` via `home.file`.

### Waybar module icon/glyph notes

Nerd Font glyph codepoints cannot be written as Nix string escapes (`\uXXXX`) — they must be pasted as literal UTF-8 characters into the `.nix` source. This applies to `format`, `format-icons`, and any other string field that displays a glyph.

The `format` fields for `custom/sep-*` and `custom/power` modules, and the workspace `format-icons`, must be edited manually in the source if glyphs need changing. Do not replace them with escape sequences.

Font variant matters: `"Hack Nerd Font"` (proportional) covers the full Nerd Font glyph set. `"Hack Nerd Font Mono"` (monospace) drops many glyphs. The CSS in `waybar.nix` explicitly sets `"Hack Nerd Font"` via `window#waybar, window#waybar *` to override Stylix's prepended `*` block (which sets the Mono variant).

## MIME associations

MIME defaults are set in `homeManagerModules/services/xdg.nix`, not in individual program modules:
- `text/*` → nvim
- `application/pdf` → zathura
- `image/*` → swayimg
- `video/*` → mpv

## Adding a new GUI program module

See `skills/new-home-module.md`.
