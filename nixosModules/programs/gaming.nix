{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.programs.gaming;
in
{
  options.myModules.programs.gaming = {
    enable = lib.mkEnableOption "Gaming support (Steam, Lutris, gamemode, mangohud)";
  };

  config = lib.mkIf cfg.enable {
    programs.steam.enable    = true;
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      lutris
      mangohud
    ];
  };
}
