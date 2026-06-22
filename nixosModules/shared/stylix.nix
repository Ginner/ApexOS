{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myModules.shared.stylix;
in
{
  options.myModules.shared.stylix = {
    enable = lib.mkEnableOption "Enable Stylix theming system";

    image = lib.mkOption {
      type = lib.types.path;
      default = ../../assets/default/wallpaper.jpg;
      description = "Wallpaper image for theming";
    };

    polarity = lib.mkOption {
      type = lib.types.enum [
        "light"
        "dark"
      ];
      default = "dark";
      description = "Color scheme polarity";
    };

    base16Scheme = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.base16-schemes}/share/themes/google-dark.yaml";
      description = "Base16 color scheme to use";
    };

    cursor = {
      package = lib.mkOption {
        type = lib.types.package;
        default = inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default;
        description = "Cursor theme package";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "rose-pine-hyprcursor";
        description = "Cursor theme name";
      };

      size = lib.mkOption {
        type = lib.types.int;
        default = 16;
        description = "Cursor size";
      };
    };

    fonts = {
      monospace = {
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.nerd-fonts.hack;
          description = "Monospace font package";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "Hack Nerd Font Mono";
          description = "Monospace font name";
        };
      };

      sizes = {
        terminal = lib.mkOption {
          type = lib.types.int;
          default = 11;
          description = "Terminal font size";
        };

        desktop = lib.mkOption {
          type = lib.types.int;
          default = 11;
          description = "Desktop font size";
        };

        applications = lib.mkOption {
          type = lib.types.int;
          default = 11;
          description = "Application font size";
        };

        popups = lib.mkOption {
          type = lib.types.int;
          default = 14;
          description = "Popup font size";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      image = cfg.image;
      polarity = cfg.polarity;
      base16Scheme = cfg.base16Scheme;
      cursor = {
        package = cfg.cursor.package;
        name = cfg.cursor.name;
        size = cfg.cursor.size;
      };
      fonts = {
        monospace = {
          package = cfg.fonts.monospace.package;
          name = cfg.fonts.monospace.name;
        };
        sizes = {
          terminal = cfg.fonts.sizes.terminal;
          desktop = cfg.fonts.sizes.desktop;
          applications = cfg.fonts.sizes.applications;
          popups = cfg.fonts.sizes.popups;
        };
      };
      targets.kmscon.enable = false; # 2026.06.03: Temp fix for deprecated kmscon definitions
    };

    fonts.packages = with pkgs; [
      nerd-fonts.hack
      nerd-fonts.fira-code
    ];
  };
}
