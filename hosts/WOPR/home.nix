{ config, pkgs, inputs, lib, ... }:
{
  imports = [
    ../../homeManagerModules
    ../../users/ginner/home.nix
    inputs.nixvim.homeModules.nixvim
    inputs.walker.homeManagerModules.walker
  ];

  myHomeModules.desktop.enable = true;

  myHomeModules.guiPrograms.signal.enable = true;

  # Host wallpaper
  stylix.image = ../../assets/wall.jpeg;

  myHomeModules.guiPrograms.waybar = {
    # TODO: replace with the actual connector name once hardware is known
    # (run `hyprctl monitors` after first boot to find it).
    output   = "DP-4";
    noBattery = true;
  };

  myHomeModules.guiPrograms.hyprland.isDesktop = true;

  # Host-specific input device settings.
  # TODO: populate after first boot — run `hyprctl devices` to find names.
  # wayland.windowManager.hyprland.settings = {
  #   "device[<keyboard-id>]" = {
  #     sensitivity = 0.0; accel_profile = "flat";
  #   };
  # };
  wayland.windowManager.hyprland.settings = {
    monitor = lib.mkForce [
      "desc:Dell Inc. DELL U2717D T4F1X87A735S, preferred, 0x0, 1.0"
      "desc:Dell Inc. DELL U2417H 5K9YD734A3ES, preferred, 2560x-140, 1.0, transform, 3"
    ];

    # TEX Shinobi external keyboard TrackPoint
    "device[usb-hid-keyboard-mouse]" = {
      sensitivity = 0.0;
      accel_profile = "flat";
      natural_scroll = false;
    };
  };

  home.stateVersion = "25.11";
}
