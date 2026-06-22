# AGENTS.md — ApexOS Root

## Scope

This repository is the reusable ApexOS layer. Concrete host and user
configuration lives in separate consuming flakes.

## Repository Boundaries

ApexOS owns:

- reusable NixOS modules in `nixosModules/`
- reusable Home Manager modules in `homeManagerModules/`
- hardware/user-experience bundles such as laptop, desktop, and server
- public fallback assets in `assets/default/`
- helper functions exported from `flake.nix`

ApexOS must not contain:

- concrete `nixosConfigurations`
- host hardware configuration
- personal user modules
- `.sops.yaml` or encrypted personal secret files
- ApexMail configuration
- private or host-specific assets

## Consumer Model

Host flakes import ApexOS and user flakes. A host flake should produce its own
`nixosConfigurations.<HOSTNAME>` and can use `apex-os.lib.mkHost` for the
standard module wiring.

User flakes own identity and cross-host preferences. ApexMail belongs in a user
flake, not in ApexOS.

## Module Conventions

- NixOS options live under `myModules.*`.
- Home Manager options live under `myHomeModules.*`.
- Bundles set enables with `lib.mkDefault` so host repos can override them.
- Do not hardcode hostnames or usernames in modules.
- Use `config.userGlobals.username` when a NixOS module needs the primary user.

## Assets

Reusable defaults live under `assets/default/`. Modules should expose options
for assets instead of hardcoding personal paths.

## Secrets

Secrets and PII are owned by user or host repos. Do not add plaintext secrets,
private keys, `.sops.yaml`, or encrypted personal secret files to ApexOS.
