{
  config,
  lib,
  pkgs,
  ...
}:

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
      plugins = {
        smart-enter = pkgs.yaziPlugins.smart-enter;
      };
      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = "l";
              run = "plugin smart-enter";
              desc = "Enter child dir or open file";
            }
            {
              on = "q";
              run = "close";
              desc = "Close tab or quit";
            }
            {
              on = "Q";
              run = "quit";
              desc = "Quit and cd to current dir";
            }
            {
              on = "<C-c>";
              run = "noop";
            }
            {
              on = "T";
              run = ''shell '${pkgs.kitty}/bin/kitty --detach --directory "$PWD"' --orphan'';
              desc = "Open terminal here";
            }
            {
              on = [
                "g"
                "I"
              ];
              run = "cd ~/INBOX";
              desc = "Go to ~/INBOX";
            }
          ];
          ratio = [
            1
            3
            4
          ];
        };
      };
      settings = {
        preview = {
          wrap = "no";
        };
        opener = {
          edit = [
            {
              run = ''kitty --detach nvim "$@"'';
              desc = "Neovim";
              block = false;
              orphan = true;
              for = "linux";
            }
          ];
          pdf = [
            {
              run = ''${pkgs.xdg-utils}/bin/xdg-open "$1"'';
              desc = "Open with default app";
              block = false;
              orphan = true;
            }
            {
              run = ''${pkgs.zathura}/bin/zathura "$1"'';
              desc = "Zathura";
              block = false;
              orphan = true;
              for = "linux";
            }
          ];
          image = [
            {
              run = ''${pkgs.xdg-utils}/bin/xdg-open "$1"'';
              desc = "Open with default app";
              block = false;
              orphan = true;
            }
            {
              run = ''${pkgs.swayimg}/bin/swayimg "$1"'';
              desc = "Swayimg";
              block = false;
              orphan = true;
              for = "linux";
            }
          ];
          svg = [
            {
              run = ''${pkgs.xdg-utils}/bin/xdg-open "$1"'';
              desc = "Open with default app";
              block = false;
              orphan = true;
            }
            {
              run = ''${pkgs.swayimg}/bin/swayimg "$1"'';
              desc = "Swayimg";
              block = false;
              orphan = true;
              for = "linux";
            }
          ]
          ++ lib.optionals (config.myHomeModules.guiPrograms.inkscape.enable or false) [
            {
              run = ''${pkgs.inkscape}/bin/inkscape "$1"'';
              desc = "Inkscape";
              block = false;
              orphan = true;
              for = "linux";
            }
          ];
          open = [
            {
              run = ''${pkgs.xdg-utils}/bin/xdg-open "$1"'';
              desc = "Open with default app";
              block = false;
              orphan = true;
            }
          ];
        };
        open.rules = [
          {
            mime = "image/svg+xml";
            use = [
              "svg"
              "reveal"
            ];
          }
          {
            mime = "image/*";
            use = [
              "image"
              "reveal"
            ];
          }
          {
            mime = "application/pdf";
            use = [
              "pdf"
              "reveal"
            ];
          }
          {
            url = "*.{py,nix,js,jsx,ts,tsx,rs,go,lua,sh,bash,zsh,fish,c,h,cpp,hpp,java,kt,kts,rb,php,css,scss,html,xml,json,jsonc,toml,yaml,yml,md,sql}";
            use = [
              "edit"
              "open"
              "reveal"
            ];
          }
          {
            mime = "text/*";
            use = [
              "edit"
              "open"
              "reveal"
            ];
          }
          {
            mime = "*";
            use = [
              "open"
              "reveal"
            ];
          }
        ];
      };
      shellWrapperName = "y";
    };
    stylix.targets.yazi.enable = true;
  };

}
