{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myHomeModules.guiPrograms.quickshell;
  toLua = lib.generators.toLua { };
  launch = command: [
    "hyprctl"
    "dispatch"
    "hl.dsp.exec_cmd(${toLua command})"
  ];
  launchFloat = command: [
    "hyprctl"
    "dispatch"
    "hl.dsp.exec_cmd(${toLua command}, { float = true })"
  ];
  monitor = pkgs.writeScript "apex-bar-monitor" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ./monitor.py}
  '';
  settings = {
    inherit (cfg)
      output
      dockedOutput
      noBattery
      logo
      height
      fontSize
      fontFamily
      ;
    # The Stylix colour set is also coercible to a palette file path. Select
    # the actual values so toJSON does not serialize that path instead.
    colors = lib.genAttrs [ "base01" "base03" "base05" "base08" "base0A" "base0D" ] (
      name: config.lib.stylix.colors.withHashtag.${name}
    );
    monitorCommand = [
      (toString monitor)
    ]
    ++ lib.optionals (cfg.temperaturePath != null) [
      "--temperature"
      cfg.temperaturePath
    ]
    ++ lib.optionals (!cfg.noBattery) [
      "--backlight"
      cfg.backlightDevice
    ];
    brightnessCommand = [
      "${pkgs.brightnessctl}/bin/brightnessctl"
      "--class=backlight"
    ]
    ++ lib.optionals (cfg.backlightDevice != "") [ "--device=${cfg.backlightDevice}" ];
    inhibitCommand = [
      "${pkgs.systemd}/bin/systemd-inhibit"
      "--what=idle:sleep"
      "--mode=block"
      "--who=ApexOS Quickshell"
      "--why=Bar stay-awake control"
      "${pkgs.coreutils}/bin/sleep"
      "infinity"
    ];
    commands = {
      audioSettings = launch "${pkgs.pavucontrol}/bin/pavucontrol -t 4";
      bluetoothSettings = launch "${pkgs.blueman}/bin/blueman-manager";
      notifications = [
        "${pkgs.swaynotificationcenter}/bin/swaync-client"
        "-t"
      ];
      lock = [ "${config.programs.hyprlock.package}/bin/hyprlock" ];
      poweroff = [
        "${pkgs.systemd}/bin/systemctl"
        "poweroff"
      ];
      reboot = [
        "${pkgs.systemd}/bin/systemctl"
        "reboot"
      ];
      previousWorkspace = [
        "hyprctl"
        "dispatch"
        ''hl.dsp.focus({ workspace = "e-1" })''
      ];
      nextWorkspace = [
        "hyprctl"
        "dispatch"
        ''hl.dsp.focus({ workspace = "e+1" })''
      ];
    };
    networkMenu = [
      {
        label = "Disable Wi-Fi";
        command = [
          "${pkgs.networkmanager}/bin/nmcli"
          "radio"
          "wifi"
          "off"
        ];
      }
      {
        label = "Enable Wi-Fi";
        command = [
          "${pkgs.networkmanager}/bin/nmcli"
          "radio"
          "wifi"
          "on"
        ];
      }
      {
        label = "Network manager";
        command = launchFloat "${pkgs.kitty}/bin/kitty -e ${pkgs.networkmanager}/bin/nmtui";
      }
      {
        label = "Edit connections";
        command = launch "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
      }
    ];
    controlMenu = [
      {
        label = "Monitor system";
        children = [
          {
            label = "htop";
            command = launchFloat "${pkgs.kitty}/bin/kitty -e ${pkgs.htop}/bin/htop";
          }
          {
            label = "btop";
            command = launchFloat "${pkgs.kitty}/bin/kitty -e ${pkgs.btop}/bin/btop";
          }
          {
            label = "powertop";
            command = launchFloat "${pkgs.kitty}/bin/kitty -e /run/wrappers/bin/pkexec ${pkgs.powertop}/bin/powertop";
          }
        ];
      }
      {
        label = "Theme settings";
        children = [
          {
            label = "GTK settings";
            command = launch "${pkgs.nwg-look}/bin/nwg-look";
          }
          {
            label = "Qt6 settings";
            command = launch "${pkgs.qt6Packages.qt6ct}/bin/qt6ct";
          }
          {
            label = "Kvantum settings";
            command = launch "${pkgs.kdePackages.qtstyleplugin-kvantum}/bin/kvantummanager";
          }
        ];
      }
    ]
    ++ lib.optional (cfg.refreshRateActions != [ ]) {
      label = "Refresh rate";
      children = cfg.refreshRateActions;
    }
    ++ [
      {
        label = "Reload Hyprland";
        command = [
          "hyprctl"
          "reload"
        ];
      }
    ];
    nmcli = "${pkgs.networkmanager}/bin/nmcli";
  };
  shell = pkgs.runCommand "apex-quickshell-config" { } ''
    mkdir -p "$out"
    cp ${./qml}/* "$out/"
    cp ${pkgs.writeText "Settings.qml" ''
      pragma Singleton
      import QtQuick
      QtObject {
        readonly property var data: ${builtins.toJSON settings}
        readonly property color background: data.colors.base01
        readonly property color foreground: data.colors.base05
        readonly property color muted: data.colors.base03
        readonly property color accent: data.colors.base0D
        readonly property color warning: data.colors.base0A
        readonly property color critical: data.colors.base08
        readonly property int height: data.height
      }
    ''} "$out/Settings.qml"
  '';
in
{
  options.myHomeModules.guiPrograms.quickshell = {
    enable = lib.mkEnableOption "ApexOS Quickshell status bar";
    package = lib.mkPackageOption pkgs "quickshell" { };
    output = lib.mkOption {
      type = lib.types.str;
      default = "eDP-1";
      description = "Primary output connector or description (optionally prefixed with desc:). Empty means all outputs.";
    };
    dockedOutput = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Preferred docked output connector or description. Automatically replaces the primary bar while available; no Kanshi restart is needed.";
    };
    noBattery = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Omit battery and backlight widgets on desktop hosts.";
    };
    logo = lib.mkOption {
      type = lib.types.path;
      default = ../../../assets/default/logo.svg;
      description = "Logo for the session-controls drawer.";
    };
    height = lib.mkOption {
      type = lib.types.ints.between 24 64;
      default = 29;
      description = "Height of the pointed bar segments in logical pixels.";
    };
    fontSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 14;
      description = "Bar text size in logical pixels.";
    };
    fontFamily = lib.mkOption {
      type = lib.types.str;
      default = config.stylix.fonts.monospace.name;
      description = "Bar font; use a Nerd Font for status icons.";
    };
    temperaturePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/sys/class/hwmon/hwmon1/temp1_input";
      description = "Runtime sysfs temperature path in millidegrees Celsius. Null auto-detects a CPU sensor, falling back to thermal zones.";
    };
    backlightDevice = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Backlight device name under /sys/class/backlight. Empty auto-detects the first device.";
    };
    refreshRateActions = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            label = lib.mkOption { type = lib.types.str; };
            command = lib.mkOption { type = lib.types.listOf lib.types.str; };
          };
        }
      );
      default = [ ];
      description = "Host-specific refresh-rate menu entries, as labels and command argument lists.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(config.myHomeModules.guiPrograms.waybar.enable or false);
        message = "Disable myHomeModules.guiPrograms.waybar when enabling the Quickshell bar.";
      }
      {
        assertion = lib.versionAtLeast cfg.package.version "0.3.1";
        message = "The ApexOS bar requires Quickshell 0.3.1 or newer (ext-workspace and Lua Hyprland support).";
      }
    ];
    programs.quickshell = {
      enable = true;
      package = cfg.package;
      activeConfig = "apex";
      configs.apex = shell;
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };
    };
    systemd.user.services.quickshell = {
      Unit.PartOf = [ "hyprland-session.target" ];
      Service = {
        RestartSec = 2;
        # hyprctl must match the compositor provided by the host, not nixpkgs.
        Environment = [ "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin" ];
      };
    };
    services.playerctld.enable = true;
  };
}
