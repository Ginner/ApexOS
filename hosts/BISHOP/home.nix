{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ../../homeManagerModules
    ../../users/ginner/home.nix  # User-specific home-manager config
    inputs.nixvim.homeModules.nixvim
    inputs.walker.homeManagerModules.walker
  ];
  # Enable laptop home configuration
  myHomeModules.laptop.enable = true;

  myHomeModules.guiPrograms.signal.enable = true;

  # Override stylix wallpaper for BISHOP (NixOS module handles the rest via autoImport)
  stylix.image = ../../assets/wall.jpeg;

  myHomeModules.guiPrograms.waybar = {
    output       = "eDP-1";
    # Use the stable monitor description string (not the connector name like
    # "DP-8", which can change between boots/docking events).
    dockedOutput = "Dell Inc. DELL U2717D T4F1X87A735S";
  };

  # Host-specific display configuration
  services.kanshi.settings = [
    {
      profile.name = "undocked";
      profile.outputs = [
        { criteria = "eDP-1"; scale = 1.2; status = "enable"; }
      ];
      profile.exec = [
        "brightnessctl set 40%"
        "pkill -x waybar; systemd-run --user --no-block waybar --config ${config.home.homeDirectory}/.config/waybar/config-undocked.json"
      ];
    }
    {
      profile.name = "office";
      profile.outputs = [
        { criteria = "eDP-1"; position = "0,0"; scale = 1.0; } # Remember, scale applies to size-coordinates
        { criteria = "Dell Inc. DELL U2717D T4F1X87A735S"; position = "1920,-240"; scale = 1.00; }
        { criteria = "Dell Inc. DELL U2417H 5K9YD734A3ES"; position = "4480,-290"; scale = 1.00; transform = "270"; }
      ];
      profile.exec = [
        "brightnessctl set 75%"
        "pkill -x waybar; systemd-run --user --no-block waybar --config ${config.home.homeDirectory}/.config/waybar/config-docked.json"
      ];
    }
  ];
  
  # Host-specific input device configuration
  wayland.windowManager.hyprland.settings = {
    # Disable the built-in touchpad — TrackPoint preferred
    "device[elan06c2:00-04f3:3195-touchpad]".enabled = false;

    # Internal ThinkPad TrackPoint
    "device[tpps/2-synaptics-trackpoint]" = {
      sensitivity = 0.15;
      accel_profile = "flat";
      natural_scroll = false;
    };

    # TEX Shinobi external keyboard TrackPoint
    "device[usb-hid-keyboard-mouse]" = {
      sensitivity = 0.0;
      accel_profile = "flat";
      natural_scroll = false;
    };
  };

  home.stateVersion = "22.11";
}
