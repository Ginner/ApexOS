{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.desktop;
  user = config.userGlobals.username;
in
{
  options.myModules.desktop = {
    enable = lib.mkEnableOption "Desktop-specific system configurations";

    enableMultiMonitor = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable multi-monitor support tools";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable desktop-specific services through module options
    myModules.services.pipewire.enable     = lib.mkDefault true;
    myModules.services.greetd.enable       = lib.mkDefault true;
    myModules.services.fwupd.enable        = lib.mkDefault true;
    myModules.services.tailscale.enable    = lib.mkDefault false;  # Optional
    myModules.services.kde-connect.enable  = lib.mkDefault false;  # Optional
    myModules.services.xremap.enable       = lib.mkDefault true;
    myModules.shared.stylix.enable         = lib.mkDefault true;
    myModules.programs.sops.enable         = lib.mkDefault true;
    myModules.programs.hyprland.enable     = lib.mkDefault true;
    myModules.programs.usbutils.enable     = lib.mkDefault true;
    myModules.programs.gaming.enable       = lib.mkDefault false;

    networking.networkmanager.enable = true;
    users.users.${user}.extraGroups = [ "networkmanager" ];

    environment.systemPackages = with pkgs; [
      pavucontrol
    ] ++ lib.optionals cfg.enableMultiMonitor [
      wdisplays
    ];

    # Desktop services
    services = {
      dbus.enable    = true;
      udisks2.enable = true;
      gvfs.enable    = true;
    };
  };
}
