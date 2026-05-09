# LT·HL OS

## Architecture

Configuration is split across three user-facing files. The rule: *would this setting change if the same user moved to a different machine?* If yes → host file. If no → user file.

```
hosts/<HOSTNAME>/
  configuration.nix   NixOS — hardware, bundle selection, host-level service overrides
  home.nix            Home Manager — hardware bundle, monitors, wallpaper, stateVersion

users/<USERNAME>/
  default.nix         NixOS — user-level system config (udev rules, system packages, etc.)
  home.nix            Home Manager — identity, SSH, git, email, program preferences
```

### What goes where

| Concern | File |
|---|---|
| Hardware bundle (`myModules.laptop.enable`) | `hosts/<h>/configuration.nix` |
| Host-level service overrides | `hosts/<h>/configuration.nix` |
| HM bundle (`myHomeModules.laptop.enable`) | `hosts/<h>/home.nix` |
| Monitor profiles (`kanshi`) | `hosts/<h>/home.nix` |
| Wallpaper (`stylix.image`) | `hosts/<h>/home.nix` |
| Stylix target overrides | `hosts/<h>/home.nix` |
| `home.stateVersion` | `hosts/<h>/home.nix` |
| sops age key path | `users/<u>/home.nix` |
| `sops.defaultSopsFile` pointer | `users/<u>/home.nix` |
| Git identity | `users/<u>/home.nix` |
| SSH match blocks | `users/<u>/home.nix` |
| Email accounts | `users/<u>/home.nix` |
| Program enables (user preference) | `users/<u>/home.nix` |
| User-scoped packages | `users/<u>/home.nix` |

## TODO
- [ ] calcurse — installed as a raw package in `laptop.nix`; no dedicated module yet
- [ ] cheat — installed as a raw package in `laptop.nix`; no dedicated module yet
- [ ] [cheat.sh](https://github.com/chubin/cheat.sh)/[navi](https://github.com/denisidoro/navi) — alternatives to cheat; not yet evaluated
- [ ] Add host-options: VM, WSL
- [ ] preconfigure pinentry for rbw (`pinentry-tty`)

## Pinned inputs / active workarounds

These are intentional deviations from tracking upstream `HEAD`. Each entry notes what to do when the upstream issue is resolved.

### Walker pinned to pre-regression commit

`walker` in `flake.lock` is pinned to commit `f6a8af6` (2026-03-30) because Walker 2.16.0
introduced a panic on startup (`failed to get item layout: desktopapplications`).

When a release after 2.16.0 looks clean, test it:
```bash
nix flake update walker
sudo nixos-rebuild test --flake .#BISHOP
```
If Walker launches correctly, keep the update and switch:
```bash
sudo nixos-rebuild switch --flake .#BISHOP
```

### OpenCode TUI theme not managed by Stylix

`homeManagerModules/tuiPrograms/opencode.nix` sets `programs.opencode.tui.theme = "stylix"`
explicitly, using opencode's own built-in theme of that name. Stylix does not yet have an
opencode target module — its fix is tracked at https://github.com/nix-community/stylix/issues/2264.

When Stylix ships the fix and your `stylix` flake input is updated to include it:
1. Remove `tui.theme = "stylix"` (and its comment) from `homeManagerModules/tuiPrograms/opencode.nix`
2. Rebuild — Stylix will manage opencode theming from your base16 palette automatically

## Laptop module
Dock fix: `boltctl list` -> `boltctl enroll <device-id>`

## Default module
The user is set, you need to set a password for the user with `passwd <username>`(_I'm not sure how this works in my setup..._).

## Secrets (sops-nix)

All secrets are managed by [sops-nix](https://github.com/Mic92/sops-nix) and stored encrypted in `secrets/`. Encrypted files are safe to commit — plaintext never enters the Nix store or version control.

Key configuration lives in `.sops.yaml` at the repo root.

### Fresh machine setup (one-time manual step)

This is the **only** manual step required before `nixos-rebuild switch` will work:

**Option A — bare age key (recommended):**
```bash
nix-shell -p age --run 'mkdir -p ~/.config/sops/age && age-keygen -o ~/.config/sops/age/keys.txt'
# The public key is printed to stdout — add it to .sops.yaml as &user_ginner
```

**Option B — derive from an existing passphrase-free SSH ed25519 key:**
```bash
nix-shell -p ssh-to-age --run 'mkdir -p ~/.config/sops/age && ssh-to-age -private-key -i ~/.ssh/id_ed25519 > ~/.config/sops/age/keys.txt'
# Note: the SSH key must have no passphrase for this to work
```

After generating the key, restore or rebuild `secrets/email.yaml`:
```bash
nix-shell -p sops --run 'sops secrets/email.yaml'
```

The host SSH key (`/etc/ssh/ssh_host_ed25519_key`) is used for NixOS-level decryption and is generated automatically on first boot — no setup needed there.

### Adding `.sops.yaml` keys for a new machine

1. Get the host age pubkey:
   ```bash
   nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
   ```
2. Add it to `.sops.yaml` and re-encrypt all secret files:
   ```bash
   nix-shell -p sops --run 'sops updatekeys secrets/email.yaml'
   ```

### WOPR — post-first-boot sops setup

WOPR's host age key does not exist until the machine boots for the first time (the host SSH
key is auto-generated on first boot). After booting WOPR for the first time, run the following
**on any machine that already has the `user_ginner` age key** (e.g. BISHOP):

1. **Derive the WOPR age pubkey from its SSH host key:**
   ```bash
   # Run on WOPR itself, or via ssh:
   nix-shell -p ssh-to-age --run 'cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age'
   ```

2. **Add the key to `.sops.yaml`** in the repo root. Insert a new anchor and add it to the
   WOPR creation rule:
   ```yaml
   keys:
     - &user_ginner  age1...   # existing
     - &host_bishop  age1...   # existing
     - &host_wopr    age1...   # NEW — paste pubkey from step 1 here

   creation_rules:
     - path_regex: secrets/[^/]+\.yaml$
       key_groups:
         - age:
             - *user_ginner
             - *host_bishop
             - *host_wopr   # NEW
   ```

3. **Re-encrypt all secret files** so WOPR can decrypt them:
   ```bash
   nix-shell -p sops --run 'sops updatekeys secrets/email.yaml'
   ```

4. **Commit the updated `.sops.yaml` and re-encrypted `secrets/email.yaml`**, then rebuild:
   ```bash
   sudo nixos-rebuild switch --flake .#WOPR
   ```

### Secret file structure (`secrets/email.yaml`)

Contains 6 keys: `work-address`, `work-realname`, `work-password`, `private-address`, `private-realname`, `private-password`.

These are injected into mbsync, msmtp, and neomutt config files at activation time via sops templates. No plaintext email addresses or passwords ever enter the Nix store.

## Styling (Stylix)

Theming is managed by [Stylix](https://stylix.danth.me) via the NixOS module (`stylix.nixosModules.stylix` in `flake.nix`). It applies a single theme to both system-level and Home Manager targets automatically.

**Canonical theme config**: `nixosModules/shared/stylix.nix` (enabled per-host via `myModules.shared.stylix`).

| Option | Where to change |
|---|---|
| Color scheme | `myModules.shared.stylix.base16Scheme` in host `configuration.nix` |
| Wallpaper (system) | `myModules.shared.stylix.image` in host `configuration.nix` |
| Wallpaper (user override) | `stylix.image` in host `home.nix` |
| Fonts | `myModules.shared.stylix.fonts.*` in host `configuration.nix` |
| Cursor | `myModules.shared.stylix.cursor.*` in host `configuration.nix` |
| Disable theming for a program | `stylix.targets.<name>.enable = false` in host `home.nix` |

Schemes are YAML files from `pkgs.base16-schemes` (e.g. `catppuccin-frappe.yaml`, `gruvbox-dark-hard.yaml`). Browse available schemes with `ls $(nix-build '<nixpkgs>' -A base16-schemes)/share/themes/`.

## XDG Desktop Portals

Portals provide a D-Bus API that lets sandboxed and portal-aware applications request privileged operations without direct system access. Common uses: file chooser dialogs, screen sharing (Pipewire), screenshots, suspend inhibition, and colour scheme queries.

Two backends run together — this is the standard Hyprland setup:

| Backend | Package | Handles |
|---|---|---|
| `xdg-desktop-portal-hyprland` | `pkgs.xdg-desktop-portal-hyprland` | Screen cast, screenshot (via `hyprland-share-picker`), security context |
| `xdg-desktop-portal-gtk` | `pkgs.xdg-desktop-portal-gtk` | File chooser, appearance (light/dark query), print, trash |

The priority order is `[ "hyprland" "gtk" ]` (`common.default` in `homeManagerModules/services/xdg.nix`) — Hyprland's portal is tried first; GTK handles anything it does not implement. Both must remain active; removing the GTK portal breaks file open/save dialogs in most applications.

Configuration lives entirely in `homeManagerModules/services/xdg.nix`. No host-level overrides are needed.

## Post build

### pass

pass is managed via `myHomeModules.cliPrograms.pass` (enabled by default in the laptop bundle). The store is at `$XDG_DATA_HOME/password-store`.

Two steps are required after first build:

**1. Set the GPG key:**
```bash
pass init <gpg-key-id>
```
This creates the store and sets `PASSWORD_STORE_KEY`. If migrating an existing store, just ensure your GPG key is imported and trusted.

**2. (Optional) Clone an existing store:**
```bash
git clone <repo> ~/.local/share/password-store
```

`pass-otp` (TOTP) and `pass-secret-service` (D-Bus secrets API for GUI apps) are enabled by default — no further setup needed for those.

### OpenCode
Start opencode and do `/connect` and connect to the API of choice. 

### Email (neomutt)
`agenix` secrets not available at build time + files not tracked by `git` not 'seen' by Nix → Manual steps:
```
mkdir -p ~/.config/nixos-secrets
cp users/ginner/email-config.template.nix ~/.config/nixos-secrets/email-config.nix
nvim ~/.config/nixos-secrets/email-config.nix
```

## Adding a Firefox extension

Firefox extensions are managed declaratively via the `ExtensionSettings` policy in
`homeManagerModules/guiPrograms/firefox.nix`. The policy engine matches entries by
**extension GUID** — not the extension's name, slug, or support email.

### Finding the correct GUID

Use the AMO (addons.mozilla.org) REST API. The slug is the last segment of the
extension's AMO page URL.

```bash
curl -s "https://addons.mozilla.org/api/v5/addons/addon/<slug>/" | jq -r '.guid'
```

Examples:

```bash
# Dark Reader  →  https://addons.mozilla.org/en-US/firefox/addon/darkreader/
curl -s "https://addons.mozilla.org/api/v5/addons/addon/darkreader/" | jq -r '.guid'
# addon@darkreader.org

# Bitwarden  →  https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/
curl -s "https://addons.mozilla.org/api/v5/addons/addon/bitwarden-password-manager/" | jq -r '.guid'
# {446900e4-71c2-419f-a6a7-df9c091e268b}
```

> **Common mistake**: the AMO page also shows a support email (e.g. `darkreaderapp@gmail.com`).
> This looks like an extension ID but is not — always use `jq -r '.guid'`, never `.support_email`.

### Adding the entry

In `homeManagerModules/guiPrograms/firefox.nix`, inside `ExtensionSettings`:

```nix
# My Extension:
"<guid-from-above>" = {
  install_url = "https://addons.mozilla.org/firefox/downloads/latest/<slug>/latest.xpi";
  installation_mode = "normal_installed"; # or "force_installed" to prevent disabling
  default_area = "menupanel";             # or "navbar" to pin in the address bar toolbar
};
```

`installation_mode` options:
- `normal_installed` — installed by policy, user can disable it
- `force_installed` — installed and locked on; user cannot disable it
- `blocked` — extension is blocked from being installed (used by the `"*"` catch-all)

Rebuild to apply:

```bash
sudo nixos-rebuild switch --flake .#BISHOP
