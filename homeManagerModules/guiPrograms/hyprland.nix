{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.myHomeModules.guiPrograms.hyprland;
  lua = lib.generators.mkLuaInline;
  toLua = lib.generators.toLua { };
  mkBind = key: dispatcher: {
    _args = [
      key
      (lua dispatcher)
    ];
  };
  mkModBind = key: dispatcher: mkBind (lua ''mainMod .. " + ${key}"'') dispatcher;
  mkMouseBind = key: dispatcher: {
    _args = [
      (lua ''mainMod .. " + ${key}"'')
      (lua dispatcher)
      { mouse = true; }
    ];
  };
  exec = command: "hl.dsp.exec_cmd(${toLua command})";
  effectiveStartupPrograms = lib.unique cfg.startupPrograms;
  startupScript = pkgs.writeShellScriptBin "start" (
    lib.concatMapStringsSep "\n" (p: "${p} &") effectiveStartupPrograms
  );
in
{
  options.myHomeModules.guiPrograms.hyprland = {
    enable = lib.mkEnableOption "Hyprland wayland compositor";

    startupPrograms = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      # Quickshell is managed by its Hyprland-session systemd user service.
      default = [ "swaync" ];
      description = "Programs to start with Hyprland";
    };

    isDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        When true, hypridle skips the brightness-dim listener (requires
        brightnessctl) and the suspend listener (undesirable on a desktop).
        Only the lock-on-idle and DPMS-off listeners remain active.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      package = null;
      systemd.enable = true;
      settings = {
        config = {
          general = {
            gaps_in = 2;
            gaps_out = 4;
            border_size = 2;
            layout = "dwindle";
          };

          input = {
            kb_layout = "dk";
            kb_variant = "nodeadkeys";
            follow_mouse = 1;
            natural_scroll = false;
            scroll_factor = 0.4;
            repeat_delay = 300;
            repeat_rate = 70;
          };

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
          };

          decoration = {
            rounding = 10;
            active_opacity = 1.0;
            inactive_opacity = 0.80;
            fullscreen_opacity = 1.0;
            shadow.enabled = false;
          };

          animations.enabled = false;
          dwindle.preserve_split = true;
        };

        monitor = [
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = 1.0;
          }
        ];

        mainMod = {
          _var = "SUPER";
        };

        bind = [
          (mkBind "Print" (exec "grim"))
          (mkBind "Sys_Req" (exec ''grim -g "$(slurp)"''))
          (mkBind "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_SINK@ toggle"))
          (mkBind "XF86AudioRaiseVolume" (exec "wpctl set-volume @DEFAULT_SINK@ 5%+"))
          (mkBind "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_SINK@ 5%-"))
          (mkBind "XF86ScreenSaver" (exec "pidof hyprlock || hyprlock"))
          (mkModBind "RETURN" (exec "kitty"))
          (mkModBind "Q" "hl.dsp.window.close()")
          (mkModBind "M" "hl.dsp.exit()")
          (mkModBind "V" ''hl.dsp.window.float({ action = "toggle" })'')
          (mkModBind "D" (exec "walker"))
          (mkModBind "P" "hl.dsp.window.pseudo()")
          (mkModBind "S" ''hl.dsp.layout("togglesplit")'')
          (mkModBind "H" ''hl.dsp.focus({ direction = "left" })'')
          (mkModBind "L" ''hl.dsp.focus({ direction = "right" })'')
          (mkModBind "K" ''hl.dsp.focus({ direction = "up" })'')
          (mkModBind "J" ''hl.dsp.focus({ direction = "down" })'')
          (mkModBind "SHIFT + L" ''hl.dsp.window.move({ direction = "right" })'')
          (mkModBind "SHIFT + H" ''hl.dsp.window.move({ direction = "left" })'')
          (mkModBind "SHIFT + J" ''hl.dsp.window.move({ direction = "down" })'')
          (mkModBind "SHIFT + K" ''hl.dsp.window.move({ direction = "up" })'')
          (mkModBind "T" ''hl.dsp.workspace.move({ monitor = "+1" })'')
          (mkModBind "mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
          (mkModBind "mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')
          (mkMouseBind "mouse:272" "hl.dsp.window.drag()")
        ]
        ++ lib.concatMap (
          i:
          let
            workspace = i + 1;
            key = toString (lib.mod workspace 10);
          in
          [
            (mkModBind key "hl.dsp.focus({ workspace = ${toString workspace} })")
            (mkModBind "SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString workspace} })")
          ]
        ) (lib.range 0 9);

        on = {
          _args = [
            "hyprland.start"
            (lua ''function() hl.exec_cmd("${startupScript}/bin/start") end'')
          ];
        };
      };
      # extraConfig = ''
      #   env = HYPRCURSOR_THEME,rose-pine-hyprcursor
      #   env = XCURSOR_THEME,rose-pine-hyprcursor
      #   '';
    };

    # Hyprland creates a default Lua config before Home Manager runs on the
    # first boot after migrating from hyprlang.
    xdg.configFile."hypr/hyprland.lua".force = true;

    # services.hyprpaper = {
    #   enable = true;
    #   settings = {
    #     preload = [
    #       "~/MEDIA/Pictures/wall.jpeg"
    #     ];
    #     wallpaper = [
    #       " , ~/MEDIA/Pictures/wall.jpeg"
    #     ];
    #   };
    # };

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          hide_cursor = true;
        };

        background = lib.mkForce [
          {
            path = "screenshot";
            blur_passes = 2;
            blur_size = 5;
          }
        ];

        input-field = {
          size = "300, 50";
          position = "0, -150";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          # font_color = "rgb(202, 211, 245)";
          # inner_color = "rgb(91, 96, 120)";
          # outer_color = "rgb(24, 25, 38)";
          outline_thickness = 3;
          placeholder_text = "Password...";
          shadow_passes = 2;
        };
      };
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "pidof hyprlock || hyprlock --immediate";
          after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
        };
        listener =
          lib.optionals (!cfg.isDesktop) [
            {
              timeout = 150;
              on-timeout = "brightnessctl -s set 10";
              on-resume = "brightnessctl -r";
            }
          ]
          ++ [
            {
              timeout = 300;
              on-timeout = "pidof hyprlock || hyprlock";
            }
            {
              timeout = 330;
              on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'";
              on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
            }
          ]
          ++ lib.optionals (!cfg.isDesktop) [
            {
              timeout = 1800;
              on-timeout = "systemctl suspend";
            }
          ];
      };
    };

  };
}
