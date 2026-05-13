{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.myModules.programs.hyprland;
in
{
  options.myModules.programs.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland;
    };

    security.pam.services.hyprlock.enable = true;

    services.xremap.withHypr = lib.mkDefault true;
  };
}

