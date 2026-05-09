{ config, pkgs, lib, ... }:

let
  cfg = config.myHomeModules.guiPrograms.hyprland;
  startupScript = pkgs.writeShellScriptBin "start" (
    lib.concatMapStringsSep "\n" (p: "${p} &") cfg.startupPrograms
  );
in
{
  options.myHomeModules.guiPrograms.hyprland = {
    enable = lib.mkEnableOption "Hyprland wayland compositor";

    startupPrograms = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      # waybar is intentionally absent — kanshi owns its lifecycle and starts
      # it with the correct --config for the active display profile.
      default = [ "swaync" ];
      description = "Programs to start with Hyprland";
    };

    isDesktop = lib.mkOption {
      type        = lib.types.bool;
      default     = false;
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
    systemd.enable = true;
    settings = {
      general = {
        gaps_in = "2";
        gaps_out = "4";
        border_size = "2";
        layout = "dwindle";

        # "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        # "col.inactive_border" = "rgba(595959aa)";
      };

    input = {
      kb_layout = "dk";
      kb_variant = "nodeadkeys";
      follow_mouse = "1";
      natural_scroll = "false";
      scroll_factor = "0.4";
      #"touchpad.natural_scroll" = "true";
      # sensitivity = "0";
      repeat_delay = "300";
      repeat_rate = "70";  
    };
    monitor = [
      # "eDP-1, preffered, 0x0, 1.0"
      # "DP-8, preffered, 1920x-820, 1.0"
      # "DP-7, preffered, 4480x-1035, 1.0, transform, 3"
      # ", preffered, auto, 1"
      ", preffered, auto, 1.0"
    ];
    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };

    decoration = {
      rounding = 10;
      active_opacity = 1.0;
      inactive_opacity = 0.80;
      fullscreen_opacity = 1.0;
      shadow = {
        enabled = false;
      };
    };

    animations = {
      enabled = "false";
    };

    dwindle = {
      pseudotile = "true";
      preserve_split = "true";
    };

    "$mod" = "SUPER";
    bind = [
      ", Print, exec, grim"
      ", Sys_Req, exec, grim -g \"$(slurp)\" "
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
      ", XF86ScreenSaver, exec, loginctl lock-session"
      "$mod, return, exec, kitty"
      "$mod, Q, killactive"
      "$mod, M, exit"
      "$mod, V, togglefloating"
      "$mod, d, exec, walker"
      "$mod, P, pseudo" # dwindle
      "$mod, S, togglesplit" # dwindle
      "$mod, h, movefocus, l"
      "$mod, l, movefocus, r"
      "$mod, k, movefocus, u"
      "$mod, j, movefocus, d"
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"
      "$mod SHIFT, l, movewindow, r"
      "$mod SHIFT, h, movewindow, l"
      "$mod SHIFT, j, movewindow, d"
      "$mod SHIFT, k, movewindow, u"
      "$mod, t, movecurrentworkspacetomonitor, +1"
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"
      # Move/resize windows with mainMod + LMB/RMB and dragging
      "$mod, mouse:272, movewindow"
      # "$mod, mouse:273, resizewindow"
    ];
# bind = $mainMod, R, exec, wofi --show drun
# bind = $mainMod, E, exec, dolphin
    exec-once = ''${startupScript}/bin/start'';
    };
    # extraConfig = ''
    #   env = HYPRCURSOR_THEME,rose-pine-hyprcursor
    #   env = XCURSOR_THEME,rose-pine-hyprcursor
    #   '';
  };

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
        disable_loading_bar = true;
        grace = 10;
        hide_cursor = true;
        no_fade_in = false;
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
          placeholder_text = ''Password...'';
          shadow_passes = 2;
        };
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
	before_sleep_cmd = "loginctl lock-session";
	after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = lib.optionals (!cfg.isDesktop) [
        {
          timeout    = 150;
          on-timeout = "brightnessctl -s set 10";
          on-resume  = "brightnessctl -r";
        }
      ] ++ [
        {
          timeout    = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout    = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume  = "hyprctl dispatch dpms on";
        }
      ] ++ lib.optionals (!cfg.isDesktop) [
        {
          timeout    = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

};
}
