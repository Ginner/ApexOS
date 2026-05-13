# AGENTS.md — NixOS Flake Root

## What this repo is

Personal NixOS flake configuration using a modular, bundle-based architecture. Hosts are minimal — they enable a bundle (laptop/desktop/server) and provide host-specific overrides. All reusable configuration lives in `nixosModules/` (system) and `homeManagerModules/` (user).

## Architectural mental model

```
flake.nix
  └── nixosConfigurations.<HOSTNAME>
        ├── specialArgs = { inherit inputs; }
        ├── ./hosts/<HOSTNAME>/configuration.nix    ← host-specific NixOS
        │     ├── imports ../../nixosModules         ← all modules loaded here
        │     ├── imports ../../users/<username>     ← user NixOS config
        │     ├── userGlobals.username = "..."       ← sets the primary user
        │     ├── myModules.<bundle>.enable = true   ← activates a bundle
        │     ├── myModules.*.enable = true/false    ← per-module overrides
        │     └── home-manager.users."<u>" = import ./home.nix
        │
        └── ./hosts/<HOSTNAME>/home.nix             ← host-specific HM
              ├── imports ../../homeManagerModules   ← all HM modules loaded
              ├── imports ../../users/<username>/home.nix ← user identity/prefs
              ├── myHomeModules.<bundle>.enable = true ← hardware bundle
              ├── home.stateVersion = "..."           ← host install epoch
              ├── services.kanshi.settings = [...]    ← monitor profiles
              └── stylix.image = ...                  ← wallpaper + display tweaks
```

**Core invariant**: Provisioning a new host requires ONLY:
1. A new directory under `hosts/<HOSTNAME>/`
2. Optionally a new directory under `users/<username>/`
3. Adding the host to `flake.nix` outputs
— no changes to `nixosModules/` or `homeManagerModules/`

## Secrets and PII policy

**Impure builds are not acceptable.** All evaluation must be reproducible from the flake alone — no `--impure` flag, no files outside the repo injected at eval time.

**PII and secrets are distinct concerns and must be handled differently:**

- **Secrets** (passwords, API keys, tokens): must not appear in version control **or** the Nix store. The only acceptable approach is sops-encrypted files committed to `secrets/`, with values injected at activation time via `sops.templates`.
- **PII** (email addresses, real names, usernames): must not appear in version control, but the Nix store is acceptable. PII is also stored in sops-encrypted files and injected via `sops.templates` — not because the Nix store is unsafe for PII, but because there is no mechanism to provide PII at eval time without either hardcoding it in committed files or using `--impure`.

**Impure builds are not acceptable.** All evaluation must be reproducible from the flake alone — no `--impure` flag, no files outside the repo injected at eval time. The `git add -N` trick is also not acceptable.

**Declarativeness is a core requirement.** Manual post-install steps must be minimised. Any step that cannot be automated must be documented in `README.md`. The goal is: clone repo → restore your age private key → `nixos-rebuild switch` → done. Generating the age private key is the one genuinely irreducible manual step — it is private key material and cannot exist in the repo by definition.

**User-facing files.** A user adopting this config should only need to edit:
- `hosts/<hostname>/configuration.nix` — hostname, bundle, hardware
- `hosts/<hostname>/home.nix` — host-specific HM overrides (monitors, wallpaper)
- `users/<username>/home.nix` — user identity, module enables, sops file pointer

No changes to `nixosModules/` or `homeManagerModules/` should be required for a new host or user.

**Mandatory split convention** — the boundary between the two HM entry points is strict:

| Concern                             | File                 | Rationale                                        |
| ----------------------------------- | -------------------- | ------------------------------------------------ |
| `myHomeModules.<bundle>.enable`     | `hosts/<h>/home.nix` | Bundle choice is hardware-specific               |
| `home.stateVersion`                 | `hosts/<h>/home.nix` | Tied to when the host was first installed        |
| Monitor/display profiles (`kanshi`) | `hosts/<h>/home.nix` | Physical monitors differ per machine             |
| Wallpaper (`stylix.image`)          | `hosts/<h>/home.nix` | May vary per machine; host is the override point |
| Stylix target overrides             | `hosts/<h>/home.nix` | Display-specific theming decisions               |
| sops age key path                   | `users/<u>/home.nix` | Key lives with the user, not the host            |
| `sops.defaultSopsFile` pointer      | `users/<u>/home.nix` | Secrets belong to the user                       |
| Email accounts                      | `users/<u>/home.nix` | Identity follows the user, not the machine       |
| Git identity                        | `users/<u>/home.nix` | Portable across all hosts                        |
| SSH match blocks                    | `users/<u>/home.nix` | Remote access config is user-level               |
| Program enables (user preference)   | `users/<u>/home.nix` | e.g. `neomutt`, `khard`, `opencode`              |
| User-scoped packages                | `users/<u>/home.nix` | e.g. `rbw`                                       |

The test: *would this setting change if the same user switched to a different machine?*
- No → `users/<u>/home.nix`
- Yes → `hosts/<h>/home.nix`


## Secrets architecture (sops-nix)

Secrets are managed by [sops-nix](https://github.com/Mic92/sops-nix):
- Encrypted secret files live in `secrets/` and are safe to commit (they are sops/age-encrypted)
- Key configuration is in `.sops.yaml` at the repo root
- At the NixOS level, the host SSH ed25519 key (`/etc/ssh/ssh_host_ed25519_key`) is used for decryption — generated on first boot, no manual setup needed
- At the HM level, the user's personal age key (`~/.config/sops/age/keys.txt`) is used — this is the **one** genuinely manual step on a fresh machine (generate or restore the key)
- Secrets are injected into config files via `sops.templates`, so plaintext values never touch the Nix store
- See `README.md` for the one-time key setup procedure

## Flake inputs

| Input                | Purpose                                     |
| -------------------- | ------------------------------------------- |
| nixpkgs              | nixos-unstable channel                      |
| home-manager         | User environment management                 |
| sops-nix             | Secret management (sops + age encryption)   |
| hyprland             | Wayland compositor (from upstream flake)    |
| nixvim               | Neovim configuration as NixOS/HM module     |
| yazi                 | Terminal file manager (bleeding-edge build) |
| rose-pine-hyprcursor | Cursor theme                                |
| stylix               | System-wide theming (base16)                |
| ags                  | Shell/widget toolkit                        |
| xremap-flake         | Key remapping service                       |
| taskfinder           | Personal tool (Codeberg)                    |
| walker               | Application launcher                        |

All inputs follow `nixpkgs` via `inputs.nixpkgs.follows = "nixpkgs"`.

## How specialArgs flow

- **NixOS modules**: `specialArgs = { inherit inputs; }` in `flake.nix` → available as `inputs` in any NixOS module that declares `{ ..., inputs, ... }`
- **Home Manager modules**: `home-manager.extraSpecialArgs = { inherit inputs; }` in `hosts/<HOSTNAME>/configuration.nix` → available as `inputs` in HM modules

## Module option conventions

**Option namespace**:
- NixOS: `myModules.<category>.<name>.*` (defined in `nixosModules/`)
- Home Manager: `myHomeModules.<category>.<name>.*` (defined in `homeManagerModules/`)
- Global user: `userGlobals.username` (defined in `nixosModules/default.nix`)

**Standard module pattern** (see any service or program .nix):
```nix
{ config, lib, pkgs, ... }:
let cfg = config.myModules.services.foo; in
{
  options.myModules.services.foo = {
    enable = lib.mkEnableOption "description";
    someOption = lib.mkOption { type = lib.types.str; default = "val"; description = "..."; };
  };
  config = lib.mkIf cfg.enable { ... };
}
```

**Priority rules**:
- `lib.mkDefault` — bundle sets this; host configs win without `mkForce`
- `lib.mkForce` — overrides everything; used sparingly (e.g., server bundle disabling Hyprland)
- `lib.mkIf` — conditional config block

**Never hardcode hostnames or usernames in modules.** Use `config.userGlobals.username` for the primary user in NixOS modules.

## Standard rebuild commands

```bash
sudo nixos-rebuild switch --flake .#BISHOP   # build and activate
sudo nixos-rebuild test --flake .#BISHOP     # test without making boot default
nix flake update                              # update all inputs
nix flake check                              # validate flake
nixfmt **/*.nix                             # format
nix eval .#nixosConfigurations.BISHOP.config.services.greetd.enable  # inspect
```

## Current hosts in flake outputs

- **BISHOP** — only host in `nixosConfigurations`

## Observed conventions

- Bundle files use `lib.mkDefault` on every module enable so hosts can override
- `userGlobals.username` is consumed by `nixosModules/default.nix` for user account creation and by service modules needing the username (e.g., xremap group memberships)
- `inputs.xremap-flake.nixosModules.default` is imported directly in `hosts/BISHOP/configuration.nix` (not via nixosModules)
- sops-nix is added as both a NixOS module (`sops-nix.nixosModules.sops`) and an HM module (`sops-nix.homeManagerModules.sops`) in `flake.nix` via `home-manager.sharedModules`
- stylix is added as a NixOS module in `flake.nix`; there is a separate HM-level stylix module (`homeManagerModules/guiPrograms/stylix.nix`)

## Skills

Skill files in `skills/` contain step-by-step workflows and repo-specific patterns for common tasks. **Before beginning any task that matches a category below, read the corresponding skill file in full.**

| Task                                              | Skill file                   |
| ------------------------------------------------- | ---------------------------- |
| Adding or editing a Home Manager module           | `skills/new-home-module.md`  |
| Adding or editing a NixOS module                  | `skills/new-nixos-module.md` |
| Provisioning a new host                           | `skills/new-host.md`         |
| Adding a new user                                 | `skills/new-user.md`         |
| Any Nix expression authoring or pattern questions | `skills/nix-patterns.md`     |

## Known issues / deviations from ideal architecture

No outstanding known issues.
