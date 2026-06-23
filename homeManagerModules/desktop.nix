{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.myHomeModules.desktop;
in
{
  options.myHomeModules.desktop = {
    enable = lib.mkEnableOption "Desktop-specific home configuration";
  };

  config = lib.mkIf cfg.enable {
    # Mirror the laptop bundle, minus kanshi (no display hotplug on desktop).
    myHomeModules.services.xdg.enable              = lib.mkDefault true;
    myHomeModules.guiPrograms.firefox.enable        = lib.mkDefault true;
    myHomeModules.guiPrograms.hyprland.enable       = lib.mkDefault true;
    myHomeModules.cliPrograms.kitty.enable          = lib.mkDefault true;
    myHomeModules.guiPrograms.zathura.enable        = lib.mkDefault true;
    myHomeModules.cliPrograms.wayland-tools.enable  = lib.mkDefault true;
    myHomeModules.guiPrograms.swayimg.enable        = lib.mkDefault true;
    myHomeModules.guiPrograms.mpv.enable            = lib.mkDefault true;
    myHomeModules.tuiPrograms.nixvim.enable         = lib.mkDefault true;
    myHomeModules.tuiPrograms.btop.enable           = lib.mkDefault true;
    myHomeModules.cliPrograms.cli-tools.enable      = lib.mkDefault true;
    myHomeModules.cliPrograms.starship.enable       = lib.mkDefault true;
    myHomeModules.cliPrograms.archive-tools.enable  = lib.mkDefault true;
    myHomeModules.cliPrograms.direnv.enable         = lib.mkDefault true;
    myHomeModules.guiPrograms.walker.enable         = lib.mkDefault true;
    myHomeModules.guiPrograms.waybar.enable         = lib.mkDefault true;
    myHomeModules.tuiPrograms.yazi.enable           = lib.mkDefault true;

    # Optional applications (default = false, same policy as laptop bundle)
    myHomeModules.guiPrograms.inkscape.enable   = lib.mkDefault false;
    myHomeModules.guiPrograms.kde-connect.enable = lib.mkDefault false;
    myHomeModules.cliPrograms.latex.enable       = lib.mkDefault false;
    myHomeModules.tuiPrograms.ncspot.enable      = lib.mkDefault false;
    myHomeModules.cliPrograms.pass.enable        = lib.mkDefault false;
    myHomeModules.tuiPrograms.opencode.enable    = lib.mkDefault false;

    # Email and contacts (optional, disabled by default)
    myHomeModules.tuiPrograms.khard.enable    = lib.mkDefault false;

    home.packages = with pkgs; [
      inputs.taskfinder.packages.${pkgs.stdenv.hostPlatform.system}.default
      newsboat
      numbat
      calcurse
      imagemagick
      pinentry-tty
      cheat
      ffmpegthumbnailer
      poppler-utils
      qpdf
    ];

    myHomeModules.cliPrograms.ssh.enableControlMaster = true;
  };
}
