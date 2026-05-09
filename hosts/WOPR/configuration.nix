{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.xremap-flake.nixosModules.default
    ../../nixosModules
    ../../users/ginner
  ];

  networking.hostName = "WOPR";

  userGlobals = {
    username = "ginner";
  };

  myModules.desktop.enable = true;

  # Host-level secret decryption uses the host SSH key (auto-generated on first boot)
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; username = config.userGlobals.username; };
    users = {
      ${config.userGlobals.username} = import ./home.nix;
    };
  };

  myModules.shared.stylix = {
    enable = true;
    image  = ../../assets/wall.jpeg;
  };

  myModules.services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [ home-manager ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  system.stateVersion = "25.05";
}
