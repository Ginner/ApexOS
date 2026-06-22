{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myHomeModules.guiPrograms.waybar;
  home = config.home.homeDirectory;
  # Stylix base16 hex values (with '#' prefix) for Pango markup.
  # CSS custom properties (@baseXX) cannot be resolved in calendar format
  # strings, so we read the palette at eval time instead.
  c = config.lib.stylix.colors.withHashtag;

  awakeScript = pkgs.writeShellApplication {
    name = "waybar-awake";
    runtimeInputs = with pkgs; [
      coreutils
      procps
      systemd
      util-linux
    ];
    text = ''
      set -euo pipefail

      state_dir="''${XDG_RUNTIME_DIR:-/tmp}/waybar-awake"
      pid_file="$state_dir/pid"
      end_file="$state_dir/end"

      mkdir -p "$state_dir"

      notify_waybar() {
        pkill -RTMIN+8 waybar 2>/dev/null || true
      }

      is_running() {
        if [[ ! -r "$pid_file" ]]; then
          return 1
        fi

        local pid
        pid="$(<"$pid_file")"
        [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
      }

      cleanup_if_stale() {
        if ! is_running; then
          rm -f "$pid_file" "$end_file"
        fi
      }

      stop_inhibitor() {
        if is_running; then
          local pid
          pid="$(<"$pid_file")"
          kill -TERM "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
        fi

        rm -f "$pid_file" "$end_file"
      }

      start_inhibitor() {
        local duration="''${1:-}"

        stop_inhibitor

        if [[ -n "$duration" ]]; then
          setsid systemd-inhibit \
            --what=idle:sleep \
            --mode=block \
            --who=waybar \
            --why="Waybar awake toggle" \
            sleep "$duration" >/dev/null 2>&1 &
          echo $! > "$pid_file"
          date -d "+$duration seconds" +%s > "$end_file"
        else
          setsid systemd-inhibit \
            --what=idle:sleep \
            --mode=block \
            --who=waybar \
            --why="Waybar awake toggle" \
            sleep infinity >/dev/null 2>&1 &
          echo $! > "$pid_file"
          rm -f "$end_file"
        fi
      }

      status() {
        cleanup_if_stale

        if is_running; then
          if [[ -r "$end_file" ]]; then
            local now end remaining minutes tooltip
            now="$(date +%s)"
            end="$(<"$end_file")"
            remaining=$(( end - now ))
            if (( remaining <= 0 )); then
              stop_inhibitor
              printf '{"text":"󰛊","tooltip":"Idle inhibition off","class":"off"}\n'
              return
            fi
            minutes=$(( (remaining + 59) / 60 ))
            tooltip="Idle inhibition on: ''${minutes} min remaining"
            printf '{"text":"󰅶","tooltip":"%s","class":"on"}\n' "$tooltip"
          else
            printf '{"text":"󰅶","tooltip":"Idle inhibition on","class":"on"}\n'
          fi
        else
          printf '{"text":"󰛊","tooltip":"Idle inhibition off","class":"off"}\n'
        fi
      }

      case "''${1:-status}" in
        status)
          status
          ;;
        start)
          start_inhibitor "''${2:-}"
          notify_waybar
          ;;
        stop)
          stop_inhibitor
          notify_waybar
          ;;
        toggle)
          cleanup_if_stale
          if is_running; then
            stop_inhibitor
          else
            start_inhibitor
          fi
          notify_waybar
          ;;
        *)
          printf 'usage: waybar-awake [status|start [seconds]|stop|toggle]\n' >&2
          exit 2
          ;;
      esac
    '';
  };

  # All module definitions and layout in one place.  barConfig is called
  # once per bar instance (undocked / docked), differing only in `output`.
  # When noBattery is true, the battery widget and backlight group are omitted.
  barConfig = output: {
    layer = "top";
    output = output;
    position = "top";
    height = 25;
    margin = "5 4";
    # width is intentionally omitted — Waybar fills the output automatically.

    # ── Layout ───────────────────────────────────
    "group/left" = {
      orientation = "horizontal";
      modules = [
        "hyprland/workspaces"
        "mpris"
      ];
    };

    "group/left-hidden" = {
      orientation = "horizontal";
      drawer = {
        transition-duration = 500;
        transition-left-to-right = true;
        click-to-reveal = false;
      };
      modules = [
        "image#start"
        "custom/poweroff"
        "custom/reboot"
        "custom/lock"
      ];
    };

    "group/left-hidden-top" = {
      orientation = "horizontal";
      modules = [
        # "custom/start"
        "group/left-hidden"
      ];
    };

    "group/right" = {
      orientation = "horizontal";
      modules = [
        "group/group-volume"
      ]
      ++ lib.optionals (!cfg.noBattery) [
        "group/group-backlight"
      ]
      ++ [
        "custom/awake"
        "cpu"
        "load"
        "memory"
        "temperature"
        "bluetooth"
        "network"
      ]
      ++ lib.optionals (!cfg.noBattery) [
        "battery"
      ]
      ++ [
      ];
    };

    "group/right-hidden" = {
      orientation = "horizontal";
      drawer = {
        transition-duration = 500;
        transition-left-to-right = true;
        click-to-reveal = true;
      };
      modules = [
        "custom/arrow-left"
      ];
    };

    "group/right-hidden-top" = {
      orientation = "horizontal";
      modules = [
        "group/right-hidden"
        "custom/ctlcenter"
      ];
    };

    modules-left = [
      "group/left-hidden-top"
      "group/left"
    ];
    modules-center = [ "clock" ];
    modules-right = [
      "group/right"
      "group/right-hidden-top"
    ];

    # ── Module definitions ────────────────────────────────────────────

    "hyprland/workspaces" = {
      format = "{icon}";
      on-scroll-down = "hyprctl dispatch workspace e+1";
      on-scroll-up = "hyprctl dispatch workspace e-1";
      sort-by = "number";
      all-outputs = true;
      format-icons =
        let
          label =
            hex: n:
            "<span letter_spacing='-11120'>${hex}</span><span size='5pt' rise='2450' font_weight='bold'>${n}</span>";
          inactive = "󰋙";
        in
        {
          "1" = label inactive "1";
          "2" = label inactive "2";
          "3" = label inactive "3";
          "4" = label inactive "4";
          "5" = label inactive "5";
          "6" = label inactive "6";
          "7" = label inactive "7";
          "8" = label inactive "8";
          "9" = label inactive "9";
          "10" = label inactive "0";
          "active" = "󰋘";
          "default" = label inactive "";
          "empty" = label inactive "";
        };
      # persistent-workspaces = {
      #   "*" = [1 2 3 4 5 6 7 8 9 10];
      # };
    };

    "cpu" = {
      interval = 30;
      format = " {usage}%";
      states = {
        warning = 80;
        critical = 90;
      };
    };

    "load" = {
      interval = 30;
      format = "󰖡 {load1}%";
    };

    "memory" = {
      interval = 10;
      format = " {used:0.1f}G";
      # format   = " {used:0.1f}G/{total:0.1f}G";
      states = {
        warning = 80;
        critical = 90;
      };
      tooltip = false;
    };

    "temperature" = {
      interval = 10;
      format = "{icon} {temperatureC}°";
      critical-threshold = 90;
      format-icons = [
        ""
        ""
        ""
        ""
        ""
      ];
    };

    "backlight" = {
      scroll-step = 2;
      format = "{icon}";
      tooltip-format = "{percent}%";
      format-icons = [
        "󰃞"
        "󰃝"
        "󰃟"
        "󰃠"
      ];
    };

    "pulseaudio" = {
      format = "{icon}";
      format-bluetooth = "{icon}";
      on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
      on-click-right = "hyprctl dispatch exec 'pavucontrol -t 4'";
      tooltip-format = "{volume}%";
      format-muted = "<span size='12pt'>󰝟</span>";
      scroll-step = 2;
      format-icons = {
        headphone = "";
        hands-free = "";
        headset = "";
        phone = "";
        portable = "";
        car = "";
        default = [
          "<span size='12pt'>󰕿</span>"
          "<span size='12pt'>󰖀</span>"
          "<span size='12pt'>󰕾</span>"
        ];
      };
    };

    "pulseaudio/slider" = {
      min = 0;
      max = 100;
      cursor = true;
    };

    "backlight/slider" = {
      min = 5;
      max = 100;
      cursor = true;
    };

    "network" = {
      interval = 10;
      format-disabled = "󰤮";
      format-disconnected = "󰤫";
      format-wifi = "";
      format-ethernet = "󰈀";
      tooltip-format = "{essid}\n\nFrequency: {frequency}GHz\nStrength: {signalStrength}%\n\n{bandwidthUpBytes}   {bandwidthDownBytes}";
      menu = "on-click-right";
      menu-file = "${home}/.config/waybar/context/network.xml";
      menu-actions = {
        action-1 = "nmcli radio wifi off";
        action-2 = "nmcli radio wifi on";
        action-3 = "hyprctl dispatch exec '[float] kitty -e nmtui'";
        action-4 = "hyprctl dispatch exec nm-connection-editor";
      };
    };

    "bluetooth" = {
      format = "{}";
      format-on = "󰂰";
      format-off = "󰂲";
      format-disabled = "󰂲";
      format-no-controller = "󰂲";
      format-connected = "{device_alias}";
      format-connected-battery = "{device_alias}";
      tooltip-format = "{device_enumerate}";
      tooltip-format-enumerate-connected = "{device_alias}";
      tooltip-format-enumerate-connected-battery = "{device_alias}   {device_battery_percentage}%";
      on-click-right = "hyprctl dispatch exec blueman-manager";
    };

    "custom/awake" = {
      exec = "${awakeScript}/bin/waybar-awake status";
      return-type = "json";
      interval = 30;
      signal = 8;
      on-click = "${awakeScript}/bin/waybar-awake toggle";
      menu = "on-click-right";
      menu-file = "${home}/.config/waybar/context/awake.xml";
      menu-actions = {
        action-1 = "${awakeScript}/bin/waybar-awake start 900";
        action-2 = "${awakeScript}/bin/waybar-awake start 1800";
        action-3 = "${awakeScript}/bin/waybar-awake start 3600";
        action-4 = "${awakeScript}/bin/waybar-awake start 7200";
        action-5 = "${awakeScript}/bin/waybar-awake stop";
      };
    };

    "battery" = {
      interval = 20;
      full-at = 100;
      tooltip = true;
      format-full = "";
      format = "{icon} {capacity}%";
      format-time = "{H}:{M:02}";
      format-charging = " {capacity}% ({time})";
      format-icons = [
        "󰁺"
        "󰁻"
        "󰁼"
        "󰁽"
        "󰁾"
        "󰁿"
        "󰂀"
        "󰂂"
        "󰁹"
      ];
      states = {
        warning = 30;
        critical = 15;
      };
    };

    "clock" = {
      tooltip-format = "<tt><small>{calendar}</small></tt>";
      format-alt = "{:%H:%M %d %B %Y}";
      # Calendar format strings use Pango markup. CSS custom properties
      # (@baseXX) are not resolvable here, so we interpolate Stylix hex
      # values at eval time via config.lib.stylix.colors.withHashtag.
      calendar = {
        mode = "year";
        weeks-pos = "right";
        mode-mon-col = 3;
        format = {
          months = "<span color='${c.base05}'><b>{}</b></span>";
          days = "<span color='${c.base05}'>{}</span>";
          weeks = "<span color='${c.base0D}'><b>W{}</b></span>";
          weekdays = "<span color='${c.base0A}'><b>{}</b></span>";
          today = "<span color='${c.base0C}'><b><u>{}</u></b></span>";
        };
      };
    };

    "power-profiles-daemon" = {
      format = "{icon}";
      tooltip-format = "Power profile: {profile}";
      format-icons = {
        performance = "󰓅";
        balanced = "󰾅";
        power-saver = "󰾆";
      };
    };
    "mpris" = {
      format = "{artist} - {title}";
      tooltip-format = "{album}";
      format-paused = " {artist} - {title}";
      on-click = "playerctl play-pause";
      on-scroll-up = "playerctl previous";
      on-scroll-down = "playerctl next";
      tooltip = false;
      max-length = 45;
    };

    "image#start" = {
      path = "${cfg.logo}";
      size = 18;
      tooltip = false;
      # on-click = "walker &";
    };

    "custom/ctlcenter" = {
      tooltip = false;
      format = "[C]";
      on-click = "swaync-client -t";
      menu = "on-click-right";
      menu-file =
        if cfg.noBattery then
          "${home}/.config/waybar/context/ctlcenter-desktop.xml"
        else
          "${home}/.config/waybar/context/ctlcenter.xml";
      menu-actions = {
        action-1-1 = "hyprctl dispatch exec '[float] kitty -e htop'";
        action-1-2 = "hyprctl dispatch exec '[float] kitty -e btop'";
        action-1-3 = "hyprctl dispatch exec '[float] kitty -e pkexec powertop'";
        action-2-1 = "hyprctl dispatch exec nwg-look";
        action-2-2 = "hyprctl dispatch exec qt6ct";
        action-2-3 = "hyprctl dispatch exec kvantummanager";
      }
      // lib.optionalAttrs (!cfg.noBattery) {
        action-3-1 = "hyprctl keyword monitor 'eDP-1,1920x1080@60, auto,1'";
        action-3-2 = "hyprctl keyword monitor 'eDP-1,1920x1080@90, auto,1'";
        action-3-3 = "hyprctl keyword monitor 'eDP-1,1920x1080@144,auto,1'";
        action-4 = "hyprctl reload";
      }
      // lib.optionalAttrs cfg.noBattery {
        action-3 = "hyprctl reload";
      };
    };

    "custom/arrow-left" = {
      format = "";
      tooltip = false;
      cursor = true;
    };

    "custom/arrow-right" = {
      format = "";
      tooltip = false;
    };

    "custom/poweroff" = {
      format = "";
      tooltip-format = "Shut down";
      on-click = "poweroff";
    };

    "custom/reboot" = {
      format = "󰜉";
      tooltip-format = "Reboot";
      on-click = "reboot";
    };

    "custom/lock" = {
      format = "";
      tooltip-format = "Lock";
      on-click = "hyprlock";
    };

    "group/group-volume" = {
      orientation = "horizontal";
      drawer = {
        transition-duration = 600;
        transition-left-to-right = true;
      };
      modules = [
        "pulseaudio"
        "pulseaudio/slider"
      ];
    };

    "group/group-backlight" = {
      orientation = "horizontal";
      drawer = {
        transition-duration = 600;
        transition-left-to-right = true;
      };
      modules = [
        "backlight"
        "backlight/slider"
      ];
    };
  };

in
{
  options.myHomeModules.guiPrograms.waybar = {
    enable = lib.mkEnableOption "Waybar status bar";

    output = lib.mkOption {
      type = lib.types.str;
      default = "eDP-1";
      description = "Monitor output for the primary (undocked) bar";
    };

    dockedOutput = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Monitor description string for the docked bar (use the full
        "Make Model Serial" string as reported by hyprctl monitors, not the
        connector name which can change between boots).  When set, a second
        bar instance is generated targeting this output.  Kanshi profile.exec
        entries are responsible for killing and restarting waybar with the
        appropriate config file for each profile:
          undocked: waybar --config ~/.config/waybar/config-undocked.json
          docked:   waybar --config ~/.config/waybar/config-docked.json
      '';
    };

    noBattery = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        When true, remove the battery widget from the left drawer and the
        backlight slider group from the right side.  Set this on desktop
        hosts where neither a battery nor a backlight device is present.
      '';
    };

    logo = lib.mkOption {
      type = lib.types.path;
      default = ../../../assets/default/logo.svg;
      description = "Logo image used for the Waybar start item.";
    };
  };

  config = lib.mkIf cfg.enable {

    # Stylix injects @base00–@base0F CSS variables; we own all structural CSS.
    stylix.targets.waybar = {
      enable = true;
      addCss = false;
    };

    # Context menu XMLs — Waybar resolves menu-file at runtime, so these must
    # be real filesystem paths rather than Nix store paths.
    # When dockedOutput is set we also write two standalone JSON config files
    # that kanshi hands to waybar via --config on each profile switch.
    home.file = {
      ".config/waybar/context/network.xml".source = ./network.xml;
      ".config/waybar/context/ctlcenter.xml".source = ./ctlcenter.xml;
      ".config/waybar/context/awake.xml".source = ./awake.xml;
    }
    // lib.optionalAttrs cfg.noBattery {
      ".config/waybar/context/ctlcenter-desktop.xml".source = ./ctlcenter-desktop.xml;
    }
    // lib.optionalAttrs (cfg.dockedOutput != null) {
      ".config/waybar/config-undocked.json".text = builtins.toJSON [ (barConfig cfg.output) ];
      ".config/waybar/config-docked.json".text = builtins.toJSON [ (barConfig cfg.dockedOutput) ];
    };
    services.playerctld.enable = true;

    programs.waybar = {
      enable = true;

      # CSS is kept as a separate file for readability.
      style = builtins.readFile ./style.css;

      # When dockedOutput is set, waybar is started by kanshi with an explicit
      # --config flag, so programs.waybar.settings is irrelevant at runtime.
      # We still populate it with the primary bar so that a plain `waybar`
      # invocation (e.g. during testing) does something sensible.
      settings = [ (barConfig cfg.output) ];
    };
  };
}
