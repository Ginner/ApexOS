{ config, lib, pkgs, ... }:

let
  cfg = config.myModules.shared.nerdFonts;
in
{
  options.myModules.shared.nerdFonts = {
    enable = lib.mkEnableOption "full Nerd Fonts catalogue";
  };

  config = lib.mkIf cfg.enable {
    fonts.packages = builtins.attrValues (
      lib.filterAttrs (_: value: lib.isDerivation value) pkgs.nerd-fonts
    );
  };
}
