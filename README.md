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
- a `secrets/` directory
- ApexMail configuration

## Consumer Shape

A host repo should depend on ApexOS and one or more user repos, then export its
own `nixosConfigurations.<HOSTNAME>`:

```nix
{
  inputs = {
    apex-os.url = "github:Ginner/ApexOS/os-layer";
    user-example.url = "git+ssh://example/user-example.git";
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

While the split is being stabilised, consumers should pin ApexOS to the
`os-layer` branch. After that branch is merged, consumers can use
`github:Ginner/ApexOS`.

Host repos are the rebuild entrypoint:

```bash
sudo nixos-rebuild switch --flake .#HOSTNAME
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

User flakes own user-level `.sops.yaml` and encrypted user secrets. Host flakes
may own host-specific secrets if a machine needs them. ApexOS owns neither.

## Defaults

ApexOS includes public defaults in `assets/default/`. Host repos can override
these through module options, for example:

```nix
myModules.shared.stylix.image = ./assets/wallpaper.jpg;
myHomeModules.guiPrograms.waybar.logo = ./assets/logo.svg;
```

## LaTeX In Neovim

Enable the Home Manager LaTeX module to install TeX Live tools and enable the
NixVim LaTeX layer by default:

```nix
myHomeModules.cliPrograms.latex.enable = true;
myHomeModules.cliPrograms.latex.scheme = "medium"; # "small", "medium", or "full"
myHomeModules.tuiPrograms.nixvim.enable = true;
myHomeModules.guiPrograms.zathura.enable = true;
```

This configures VimTeX with `latexmk`, XeLaTeX, SyncTeX, Zathura viewing, Texlab
LSP, LaTeX/BibTeX Treesitter support, and `aux/` for auxiliary files while
keeping the final PDF next to the `.tex` file. Override with
`myHomeModules.tuiPrograms.nixvim.latex.enable = false;` if needed.

Add missing TeX Live packages without switching to `full`:

```nix
myHomeModules.cliPrograms.latex.extraPackages = texlive: {
  inherit (texlive) wallpaper enumitem <etc.>;
};
```
