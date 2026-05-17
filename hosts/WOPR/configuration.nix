{ config, pkgs, inputs, lib, ... }:
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

  # nVidia stuff
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      # Add additional package names here
      "nvidia-x11" # Just a name - Doesn't seem to indicate that the session must be x11...
      "nvidia-settings"
    ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;


  myModules.services.tailscale.enable = true;
  myModules.services.kde-connect.enable = true;

  environment.systemPackages = with pkgs; [ home-manager ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  system.stateVersion = "25.11";
}
