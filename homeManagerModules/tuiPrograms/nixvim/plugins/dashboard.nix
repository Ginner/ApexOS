{ config, lib, ... }:

let
  cfg = config.myHomeModules.tuiPrograms.nixvim;
  dashboardCfg = cfg.dashboard;
in
{
  options.myHomeModules.tuiPrograms.nixvim.dashboard = {
    enable = lib.mkEnableOption "NixVim dashboard" // {
      default = true;
    };

    bookmarks = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            key = lib.mkOption {
              type = lib.types.str;
              description = "Shortcut key shown in the dashboard.";
            };

            name = lib.mkOption {
              type = lib.types.str;
              description = "Bookmark label shown in the dashboard.";
            };

            path = lib.mkOption {
              type = lib.types.str;
              description = "Path opened by the dashboard bookmark.";
            };
          };
        }
      );
      default = [
        {
          key = "n";
          name = "NixVim config";
          path = "${config.xdg.configHome}/nvim/init.lua";
        }
        {
          key = "z";
          name = "Zsh config";
          path = "${config.home.homeDirectory}/.zshrc";
        }
      ];
      description = "Dashboard bookmark entries.";
    };
  };

  config = lib.mkIf (cfg.enable && dashboardCfg.enable) {
    programs.nixvim.plugins.dashboard = {
      enable = true;
      settings = {
        theme = "doom";
        config = {
          header = [
            "APEXOS"
            "NEOVIM"
          ];
          center = [
            {
              icon = " ";
              desc = "Find files";
              key = "f";
              key_format = " %s";
              action = "Telescope find_files";
            }
            {
              icon = "󰱼 ";
              desc = "Live grep";
              key = "g";
              key_format = " %s";
              action = "Telescope live_grep";
            }
          ]
          ++ map (bookmark: {
            icon = " ";
            desc = bookmark.name;
            key = bookmark.key;
            key_format = " %s";
            action.__raw = ''function() vim.cmd.edit(vim.fn.fnameescape(vim.fn.expand(${builtins.toJSON bookmark.path}))) end'';
          }) dashboardCfg.bookmarks;
          footer = [ "Reusable NixOS layer" ];
        };
      };
    };
  };
}
