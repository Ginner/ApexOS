{
  description = "System configuration flake";

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
    apex-mail = {
      url = "github:Ginner/ApexMail";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, yazi, home-manager, sops-nix, stylix, ... } @ inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      # Copy per-host, could it be 'templated'?
      BISHOP = nixpkgs.lib.nixosSystem {
      	inherit system;
        specialArgs = { inherit inputs ; };
        modules = [
          # Host configuration
          ./hosts/BISHOP/configuration.nix
	  sops-nix.nixosModules.sops
	  home-manager.nixosModules.default
          stylix.nixosModules.stylix
          {
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              nixpkgs.overlays = [
                yazi.overlays.default
              ];
            }
	];
      };
      WOPR = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/WOPR/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.default
          stylix.nixosModules.stylix
          {
            home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            nixpkgs.overlays = [
              yazi.overlays.default
            ];
          }
        ];
      };
    };
  };
}
