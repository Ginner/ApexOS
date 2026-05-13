{ config, pkgs, lib, ... }:

let
  cfg = config.myHomeModules.guiPrograms.kde-connect;
in
{
  options.myHomeModules.guiPrograms.kde-connect = {
    enable = lib.mkEnableOption "KDE Connect user service";

    enableIndicator = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable KDE Connect indicator";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Auto-start KDE Connect service";
    };
  };

  config = lib.mkIf cfg.enable {

    # Enable the user service
    services.kdeconnect = {
      enable = true;
      indicator = cfg.enableIndicator;
    };

    # Ensure XDG autostart if requested
    xdg.desktopEntries = lib.mkIf cfg.autoStart {
      kdeconnect = {
        name = "KDE Connect";
        exec = "kdeconnect-indicator";
        terminal = false;
        categories = [ "Network" ];
        startupNotify = false;
      };
    };
  };
}
