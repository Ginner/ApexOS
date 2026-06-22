# ApexOS

ApexOS is the reusable OS layer for a modular NixOS setup. It provides NixOS
modules, Home Manager modules, hardware-oriented bundles, and a small host
constructor. Concrete machines, users, secrets, and private assets live in
separate flakes that consume this one.

## Repository Role

This repo owns reusable configuration only:

- `nixosModules/` — system-level ApexOS modules and bundles
- `homeManagerModules/` — user-level ApexOS modules and bundles
- `assets/default/` — public fallback assets used by module defaults
- `lib.mkHost` — helper for host flakes that want the standard ApexOS wiring

This repo does not own:

- concrete `nixosConfigurations`
- host hardware files
- user identity configuration
- `.sops.yaml` or encrypted user secret files
- ApexMail configuration

## Consumer Shape

A host repo should depend on ApexOS and one or more user repos, then export its
own `nixosConfigurations.<HOSTNAME>`:

```nix
{
  inputs = {
    apex-os.url = "github:Ginner/ApexOS";
    user-example.url = "git+ssh://example/user-example";
  };

  outputs = { apex-os, user-example, ... }: {
    nixosConfigurations.HOSTNAME = apex-os.lib.mkHost {
      hostname = "HOSTNAME";
      username = "example";
      modules = [
        ./hardware-configuration.nix
        user-example.nixosModules.default
        ./configuration.nix
      ];
      homeModules = [
        user-example.homeManagerModules.default
        ./home.nix
      ];
    };
  };
}
```

## Split Rule

Use the question: would this setting change if the same user switched machines?

- Yes: put it in the host repo.
- No: put it in the user repo.
- Reusable for many hosts/users: put it in ApexOS.

Examples of host-owned config: hostname, hardware, bundle choice, monitor
profiles, input-device quirks, wallpapers, `system.stateVersion`, and
`home.stateVersion`.

Examples of user-owned config: Git identity, SSH match blocks, email accounts,
personal sops key path, user secrets, and ApexMail integration.

## Defaults

ApexOS includes public defaults in `assets/default/`. Host repos can override
these through module options, for example:

```nix
myModules.shared.stylix.image = ./assets/wallpaper.jpg;
myHomeModules.guiPrograms.waybar.logo = ./assets/logo.svg;
```
