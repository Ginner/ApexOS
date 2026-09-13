# AGENTS.md — homeManagerModules/tuiPrograms/

Terminal UI programs — full-screen TUI applications that work without a compositor but benefit from a capable terminal emulator.

## What qualifies as a TUI program here

- Full-screen ncurses/TUI interface
- Can run in a plain terminal over SSH
- No Wayland/X11 compositor dependency (though some integrate with Wayland tools at runtime)

## Current modules

| File | Option path | Description |
|---|---|---|
| nixvim/ | `myHomeModules.tuiPrograms.nixvim` | Neovim via nixvim — enabled by laptop bundle |
| btop.nix | `myHomeModules.tuiPrograms.btop` | System monitor |
| khard.nix | `myHomeModules.tuiPrograms.khard` | CLI contact manager (vCard/CardDAV) |
| ncspot.nix | `myHomeModules.tuiPrograms.ncspot` | Terminal Spotify client |
| neomutt.nix | `myHomeModules.tuiPrograms.neomutt` | TUI email client |
| opencode.nix | `myHomeModules.tuiPrograms.opencode` | AI coding assistant CLI |
| tmux.nix | `myHomeModules.tuiPrograms.tmux` | Terminal multiplexer |
| yazi.nix | `myHomeModules.tuiPrograms.yazi` | Terminal file manager |

## Module notes

**nixvim/default.nix**: Follows the standard `myHomeModules.tuiPrograms.nixvim.enable` pattern. The laptop bundle enables it with `mkDefault true`. Requires `inputs.nixvim.homeModules.nixvim` to be imported at the host level (`hosts/<HOSTNAME>/home.nix`). Sub-files: `options.nix`, `keymaps.nix`, `autocommands.nix`, and plugins under `plugins/` (lsp, cmp, treesitter, lualine, autoclose, mkdnflow).

**yazi.nix**: Exposes `enableZshIntegration` (default true). Configures openers for edit/pdf/image/open using `kitty`, `zathura`, `swayimg`, and `xdg-open` respectively. Shell wrapper named `y`. Enables `stylix.targets.yazi`.

**neomutt.nix**: Exposes `mailsyncCommand` (default `"mbsync -a"`) and `enableKhard` (default true, wires `khard` into neomutt's query command). Installs supporting packages: `gnupg`, `lynx`, `urlscan`, `w3m`. Account-switching macros (`i1`/`i2`) are static (work=primary, private=secondary) and `source` the per-account identity files written by sops templates in the user's `home.nix`. Does **not** depend on `accounts.email.accounts`. Email programs (mbsync, msmtp, notmuch) are managed by `services/email-accounts.nix`, not here.

**khard.nix**: Exposes `contactsPath` (default `$XDG_DATA_HOME/contacts`) and `enableCardDAV` (default false, placeholder for future vdirsyncer integration). Creates the contacts directory via HM activation.

**tmux.nix**: Exposes `enableVim` (default true, adds vim-style pane navigation and `|`/`-` splits), `enableMouse` (default true), `historyLimit` (default 10000).

**opencode.nix**: Enables OpenCode with `permission."*" = "ask"` and installs the reusable ApexOS instructions from `assets/default/opencode/`. Configures the local `nixos` MCP server using `pkgs.mcp-nixos`, enabled by default; consumers can disable it with `programs.opencode.settings.mcp.nixos.enabled = false`. User and host modules may merge additional instructions and permission overrides.

**btop.nix**: Enables `programs.btop` with `vim_keys = true`.

**ncspot.nix**: Minimal — just enables `programs.ncspot`.

## Known issues

No outstanding known issues.

## Adding a new TUI program module

See `skills/new-home-module.md`.
