{
  description = "ApexOS reusable NixOS configuration layer";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    taskfinder = {
      url = "git+https://codeberg.org/ginner/taskfinder?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tuigreet = {
      url = "github:notashelf/tuigreet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      yazi,
      home-manager,
      sops-nix,
      stylix,
      xremap-flake,
      ...
    }@inputs:
    {
      nixosModules.default = import ./nixosModules;
      homeManagerModules.default = import ./homeManagerModules;

      lib.mkHost =
        {
          hostname,
          username,
          system ? "x86_64-linux",
          modules ? [ ],
          homeModules ? [ ],
          specialArgs ? { },
          extraSpecialArgs ? { },
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          }
          // specialArgs;
          modules = [
            self.nixosModules.default
            xremap-flake.nixosModules.default
            sops-nix.nixosModules.sops
            home-manager.nixosModules.default
            stylix.nixosModules.stylix
            {
              networking.hostName = hostname;
              userGlobals.username = username;

              sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

              home-manager = {
                sharedModules = [
                  self.homeManagerModules.default
                  sops-nix.homeManagerModules.sops
                  inputs.nixvim.homeModules.nixvim
                  inputs.walker.homeManagerModules.walker
                ];
                extraSpecialArgs = {
                  inherit inputs username;
                }
                // extraSpecialArgs;
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username}.imports = homeModules;
              };

              nixpkgs.overlays = [
                yazi.overlays.default
              ];

              nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
            }
          ]
          ++ modules;
        };
    };
}
