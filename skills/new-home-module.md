# Skill: Adding a new Home Manager module

This covers adding a module to `homeManagerModules/cliPrograms/`, `guiPrograms/`, `tuiPrograms/`, or `services/`.

## Step 1: Decide where it goes

| Category | Criteria | Examples |
|---|---|---|
| cliPrograms/ | Runs in TTY; no Wayland/X11 dependency | zsh, ssh, git, starship, kitty |
| guiPrograms/ | Requires Wayland compositor | hyprland, firefox, mpv, quickshell |
| tuiPrograms/ | Full-screen TUI; no compositor needed | nixvim, btop, yazi, ncspot, neomutt |
| services/ | User-level background services | xdg portals, mbsync/msmtp email |

---

## Step 2: Create the module file

Example: `homeManagerModules/cliPrograms/mytool.nix`

```nix
{ config, lib, pkgs, ... }:

let
  cfg = config.myHomeModules.cliPrograms.mytool;
in
{
  options.myHomeModules.cliPrograms.mytool = {
    enable = lib.mkEnableOption "My tool description";

    # Add configurable options:
    someOption = lib.mkOption {
      type = lib.types.str;
      default = "default-value";
      description = "What this does";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mytool = {
      enable = true;
      # ...
    };

    # Packages not managed by programs.*:
    home.packages = [ pkgs.mytool-extra ];
  };
}
```

**Rules**:
- Option path: `myHomeModules.<category>.<name>`
- Always gate config behind `lib.mkIf cfg.enable`
- Default for `enable` is `false`
- Use `lib.mkDefault` for values hosts should be able to override
- Prefer `xdg.configHome` over hardcoded `~/.config` paths
- If using flake inputs, add `inputs` to argument list: `{ config, lib, pkgs, inputs, ... }`

---

## Step 3: Register it in the sub-directory's default.nix

For a new CLI program, add to `homeManagerModules/cliPrograms/default.nix`:

```nix
{
  imports = [
    # ... existing imports ...
    ./mytool.nix
  ];
}
```

Same pattern for other categories.

The top-level `homeManagerModules/default.nix` already imports `./cliPrograms`, `./guiPrograms`, `./tuiPrograms`, and `./services` via the laptop.nix bundle, so no change at the top level.

Actually: `homeManagerModules/default.nix` imports all sub-directories. Adding to the sub-directory default.nix is sufficient.

---

## Step 4: Optionally add to the laptop bundle

If this tool should be on by default for laptop users, add to `homeManagerModules/laptop.nix` (inside `config = lib.mkIf cfg.enable { ... }`):

```nix
myHomeModules.cliPrograms.mytool.enable = lib.mkDefault true;
```

For optional tools (user opts in), add with `mkDefault false` — this documents that it exists without enabling it:

```nix
myHomeModules.cliPrograms.mytool.enable = lib.mkDefault false;
```

---

## Step 5: Test

```bash
# Check syntax
nix-instantiate --parse homeManagerModules/cliPrograms/mytool.nix

# Full build test
sudo nixos-rebuild test --flake .#BISHOP
```

---

## Cross-module integration patterns

**Conditional integration** (from zsh.nix):
```nix
programs.kitty.shellIntegration.enableZshIntegration =
  lib.mkIf (config.myHomeModules.guiPrograms.kitty.enable or false) (lib.mkDefault true);
```

Use `config.myHomeModules.<other>.enable or false` to check whether another module is active, rather than asserting it must be.

**Using flake packages** (from laptop.nix):
```nix
home.packages = [
  inputs.taskfinder.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

**Writing config files via home.file** (from nixvim/default.nix):
```nix
home.file.".config/mytool/config.toml".text = ''
  [section]
  key = "value"
'';
```

**Stylix integration**: Programs that support Stylix theming can opt in:
```nix
stylix.targets.mytool.enable = true;
```
Or disable if you want to control colors manually:
```nix
stylix.targets.mytool.enable = false;
```
