{ config, pkgs, lib, ... }:

let
  cfg = config.myHomeModules.cliPrograms.wayland-tools;
in
{
  options.myHomeModules.cliPrograms.wayland-tools = {
    enable = lib.mkEnableOption "Wayland-specific tools";

    clipboard = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable wl-clipboard";
    };

    screenshot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable screenshot tools (grim, slurp, swappy)";
    };

    recording = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable screen recording (wf-recorder)";
    };

    notifications = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable swaync notification daemon";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      lib.optionals cfg.clipboard [ wl-clipboard ] ++
      lib.optionals cfg.screenshot [ grim slurp swappy ] ++
      lib.optionals cfg.recording [ wf-recorder ];

    # Notification daemon — swaync (SwayNotificationCenter)
    services.swaync = lib.mkIf cfg.notifications {
      enable = true;
    };
  };
}
