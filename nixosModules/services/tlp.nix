{ pkgs, lib, config, ... }:

let
  cfg = config.myModules.services.tlp;
in
{
  options.myModules.services.tlp = {
    enable = lib.mkEnableOption "TLP power management services for laptops";

    chargeControl = {
      enable = lib.mkEnableOption "primary-user temporary TLP charge controls";
      battery = lib.mkOption {
        type = lib.types.enum [ "BAT0" "BAT1" ];
        default = "BAT0";
        description = "TLP battery targeted by the bar's full-charge and restore actions.";
      };
    };

    batteryThresholds = {
      BAT0 = {
        start = lib.mkOption {
          type = lib.types.int;
          default = 75;
          description = "Battery charge start threshold for BAT0";
        };
        stop = lib.mkOption {
          type = lib.types.int;
          default = 80;
          description = "Battery charge stop threshold for BAT0";
        };
      };
      BAT1 = {
        start = lib.mkOption {
          type = lib.types.int;
          default = 75;
          description = "Battery charge start threshold for BAT1";
        };
        stop = lib.mkOption {
          type = lib.types.int;
          default = 80;
          description = "Battery charge stop threshold for BAT1";
        };
      };
    };
    extraSettings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.str lib.types.int );
      default = {};
      description = "Additional TLP settings";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.tlp = {
        enable = true;
        settings = {
          START_CHARGE_THRESH_BAT0 = cfg.batteryThresholds.BAT0.start;
          STOP_CHARGE_THRESH_BAT0 = cfg.batteryThresholds.BAT0.stop;
          START_CHARGE_THRESH_BAT1 = cfg.batteryThresholds.BAT1.start;
          STOP_CHARGE_THRESH_BAT1 = cfg.batteryThresholds.BAT1.stop;
         } // cfg.extraSettings;
      };

    environment.systemPackages = with pkgs; [
      # powertop # Only applicable to Intel laptops
      tlp
      acpi
    ];

    services.acpid.enable = true;
    services.upower.enable = true;
    }
    (lib.mkIf cfg.chargeControl.enable {
      security.sudo.extraRules = [ {
        users = [ config.userGlobals.username ];
        runAs = "root";
        commands = map (action: {
          command = "${config.services.tlp.package}/bin/tlp ${action} ${cfg.chargeControl.battery}";
          options = [ "NOPASSWD" ];
        }) [ "fullcharge" "setcharge" ];
      } ];
    })
  ]);
}
