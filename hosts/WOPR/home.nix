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
    output   = "DP-1";
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

  home.stateVersion = "25.05";
}
