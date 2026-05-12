{ config, lib, pkgs, ... }:

let
  cfg = config.myHomeModules.tuiPrograms.yazi;
in
{
  options.myHomeModules.tuiPrograms.yazi = {
    enable = lib.mkEnableOption "Yazi terminal file manager";

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable zsh integration";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = cfg.enableZshIntegration;
      plugins = { smart-enter = pkgs.yaziPlugins.smart-enter; };
      keymap = {
        mgr = {
          prepend_keymap = [
            { on = "l"; run = "plugin smart-enter"; desc = "Enter child dir or open file"; }
            { on = ["g" "I"]; run = "cd ~/INBOX"; desc = "Go to ~/INBOX"; }
          ];
          ratio = [ 1 3 4 ];
        };
      };
      settings = {
        preview = {
          wrap = "no";
        };
        opener = {
          edit = [
            { run = ''kitty --detach nvim "$@"''; block = false; orphan = true; for = "linux"; }
          ];
          pdf = [
            { run = ''${pkgs.zathura}/bin/zathura "$1"''; block = false; orphan = true; for = "linux"; }
          ];
          image = [
            { run = ''${pkgs.swayimg}/bin/swayimg "$1"''; block = false; orphan = true; for = "linux"; }
          ];
          open = [
            { run = '' ${pkgs.xdg-utils}/bin/xdg-open "$1"''; block = false; orphan = true; }
          ];
        };
        open.rules = [
            { mime = "text/*"; use = [ "edit" "reveal" ]; }
            { mime = "application/pdf"; use = [ "pdf" "reveal" ]; }
            { mime = "image/*"; use = [ "image" "reveal" ]; }
          ];
      };
      shellWrapperName = "y";
    };
    stylix.targets.yazi.enable = true;
  };

}
