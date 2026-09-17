# AGENTS.md — homeManagerModules/

User-level Home Manager modules. Same option-gating philosophy as `nixosModules/` but for the user environment.

## File structure

```
homeManagerModules/
  default.nix       ← imports everything; defines myHomeModules.default and baseline HM config
  laptop.nix        ← HM bundle for laptop users
  cliPrograms/      ← terminal tools with no display dependency (see cliPrograms/AGENTS.md)
  guiPrograms/      ← GUI programs requiring a display/compositor (see guiPrograms/AGENTS.md)
  tuiPrograms/      ← terminal UI programs (ncurses, full-screen TUIs) (see tuiPrograms/AGENTS.md)
  services/         ← user-level services (xdg portals, email sync, etc.) (see services/AGENTS.md)
```

## default.nix

Defines `myHomeModules.default.enable` (bool, default true). Gated behind it:
- `home.username = lib.mkDefault username` — derived from `extraSpecialArgs.username`, which hosts set to `config.userGlobals.username`
- `home.homeDirectory = lib.mkDefault "/home/${username}"` — same
- `home.preferXdgDirectories = true`
- Default packages: `git`
- Default module enables: `myHomeModules.cliPrograms.{git,ssh,zsh}.enable = mkDefault true`
- `home.sessionVariables.EDITOR = "nvim"`
- `programs.home-manager.enable = true`

## laptop.nix (HM bundle)

`myHomeModules.laptop.enable` enables the following with `mkDefault true`:
- xdg, ags, firefox, hyprland, kitty, zathura, wayland-tools, kanshi, swayimg, mpv, nixvim, btop, cli-tools, starship, archive-tools, direnv, walker, quickshell, yazi, pass (password manager)

Set to `mkDefault false` (available but opt-in):
- inkscape, kde-connect, latex, ncspot, opencode, neomutt, khard, email-accounts

Direct config set by the bundle (not via module options):
- Laptop-specific packages: taskfinder, newsboat, numbat, calcurse, imagemagick, pinentry-tty, cheat, ffmpegthumbnailer, poppler
- `myHomeModules.cliPrograms.ssh.enableControlMaster = true`

## Option convention

```nix
{ config, lib, pkgs, ... }:
let cfg = config.myHomeModules.<category>.<name>; in
{
  options.myHomeModules.<category>.<name> = {
    enable = lib.mkEnableOption "<description>";
    # Additional options
  };
  config = lib.mkIf cfg.enable { ... };
}
```

All `enable` defaults to false unless the bundle sets `mkDefault true`.

## Category breakdown

| Directory | Contains | Requires display? |
|---|---|---|
| cliPrograms/ | Shell tools, terminal emulator, SSH, git | No |
| guiPrograms/ | Firefox, Hyprland, Quickshell, Zathura, MPV, etc. | Yes (Wayland) |
| tuiPrograms/ | Neovim (nixvim), btop, yazi, ncspot, neomutt, khard, opencode, tmux | No |
| services/ | xdg portals, email accounts (mbsync/msmtp) | Mixed |

## Flake modules in HM

These are added via `imports` in `hosts/<HOSTNAME>/home.nix` (not inside homeManagerModules):
- `inputs.nixvim.homeModules.nixvim` — required by the nixvim config
- `inputs.ags.homeManagerModules.default` — for ags widget system
- `inputs.walker.homeManagerModules.walker` — for Walker launcher

They arrive with `extraSpecialArgs = { inherit inputs; }` from `configuration.nix`.

## Known issues

No outstanding known issues.
