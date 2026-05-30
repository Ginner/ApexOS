{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.myModules.services.greetd;
  tuigreet = inputs.tuigreet.packages.${pkgs.stdenv.hostPlatform.system}.tuigreet;
in
{
  options.myModules.services.greetd = {
    enable = lib.mkEnableOption "Enable greetd display manager";
    sessionCommand = lib.mkOption {
      type = lib.types.str;
      default = "${tuigreet}/bin/tuigreet --time --remember --cmd start-hyprland";
      description = "Command for default greetd session";
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings.default_session.command = cfg.sessionCommand;
    };
    systemd.services.greetd.serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "journal";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
    };
  };
}
