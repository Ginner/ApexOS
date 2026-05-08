# AGENTS.md — homeManagerModules/cliPrograms/

Terminal programs and tools that do not depend on a display server or compositor.

## What qualifies as a CLI program here

- Can run in a plain TTY or over SSH
- No Wayland/X11 dependency
- Includes: shell, shell prompt, terminal emulator, SSH, git, text processing tools

## Current modules

| File | Option path | Description |
|---|---|---|
| archive-tools.nix | `myHomeModules.cliPrograms.archive-tools` | Archiving tools (tar, zip, etc.) |
| cli-tools.nix | `myHomeModules.cliPrograms.cli-tools` | General CLI utilities |
| direnv.nix | `myHomeModules.cliPrograms.direnv` | Per-directory env vars |
| git.nix | `myHomeModules.cliPrograms.git` | Git config |
| kitty.nix | `myHomeModules.cliPrograms.kitty` | Kitty terminal emulator |
| latex.nix | `myHomeModules.cliPrograms.latex` | LaTeX toolchain |
| pass.nix | `myHomeModules.cliPrograms.pass` | pass password manager (pass-wayland + pass-otp + pass-secret-service) |
| scripts.nix | `myHomeModules.cliPrograms.scripts` | Custom shell scripts (mailias, sermail) |
| ssh.nix | `myHomeModules.cliPrograms.ssh` | SSH client + match blocks |
| starship.nix | `myHomeModules.cliPrograms.starship` | Starship shell prompt |
| wayland-tools.nix | `myHomeModules.cliPrograms.wayland-tools` | Wayland utilities (wl-clipboard, grim, slurp, swaync notification daemon) |
| zsh.nix | `myHomeModules.cliPrograms.zsh` | Zsh shell config |

## Observed patterns

**zsh.nix**: Exposes fine-grained options (`enableAutosuggestions`, `enableSyntaxHighlighting`, `enableCompletion`, `enableAutocd`, `dotDir`, `extraInit`). All default to sensible values. Sets aliases including `ls = "eza"`. History stored at `${config.xdg.dataHome}/zsh/history`. Auto-detects kitty integration if kitty is enabled.

**ssh.nix**: Exposes `enableControlMaster`, `matchBlocks` (passed through to `programs.ssh.matchBlocks`), `extraConfig`. The `matchBlocks` option type is `attrsOf anything` to accommodate the full range of `programs.ssh.matchBlocks` options. Connection multiplexing via `*` match block added when `enableControlMaster = true`.

## XDG conventions

Modules that write config files use `xdg.configHome` paths, not hardcoded `~/.config`. The `home.preferXdgDirectories = true` set in `homeManagerModules/default.nix` activates this globally.

Zsh dotDir defaults to `${config.xdg.configHome}/zsh`.

## Adding a new CLI program module

See `skills/new-home-module.md`.
