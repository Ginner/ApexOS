{ config, lib, pkgs, ... }:

let
  cfg = config.myHomeModules.guiPrograms.waybar;

  # Power menu XML written to ~/.config/waybar/power_menu.xml at activation.
  # Waybar resolves menu-file at runtime so it must be a real filesystem path.
  powerMenuXml = ''
    <?xml version="1.0" encoding="utf-8"?>
    <interface>
      <object class="GtkMenu" id="menu">
        <child>
          <object class="GtkMenuItem" id="shutdown">
            <property name="label">Shutdown</property>
          </object>
        </child>
        <child>
          <object class="GtkMenuItem" id="reboot">
            <property name="label">Reboot</property>
          </object>
        </child>
        <child>
          <object class="GtkMenuItem" id="suspend">
            <property name="label">Suspend</property>
          </object>
        </child>
        <child>
          <object class="GtkMenuItem" id="hibernate">
            <property name="label">Hibernate</property>
          </object>
        </child>
      </object>
    </interface>
  '';

  # Nerd Font Powerline solid arrows — act as pill edge caps.
  # \ue0b0 = right-pointing filled arrow (used as right cap:  ▶)
  # \ue0b2 = left-pointing filled arrow  (used as left cap:  ◀)
  # Colour matches pill background (@base01) on transparent bg,
  # creating the illusion of a pointed pill edge.
  sepRight = "󰍟"; # U+E0B0
  sepLeft  = "󰍞"; # U+E0B2

in
{
  options.myHomeModules.guiPrograms.waybar = {
    enable = lib.mkEnableOption "Waybar status bar";

    output = lib.mkOption {
      type = lib.types.str;
      default = "eDP-1";
      description = "Monitor output waybar is anchored to";
    };
  };

  config = lib.mkIf cfg.enable {

    # Stylix injects @base00–@base0F colour variables; we own the layout CSS.
    stylix.targets.waybar = {
      enable = true;
      addCss = false;
    };

    # Power menu XML at a real path Waybar can read at runtime.
    home.file.".config/waybar/power_menu.xml".text = powerMenuXml;

    programs.waybar = {
      enable = true;
      settings = {
        waybar = {
          layer    = "top";
          output   = cfg.output;
          position = "top";
          height   = 32;
          margin   = "5 0 0 0";

          modules-left = [
            "custom/power"
            "hyprland/workspaces"
            "custom/sep-right"
          ];
          modules-center = [
            "custom/sep-left-c"
            "clock"
            "custom/sep-right-c"
          ];
          modules-right = [
            "custom/sep-left"
            "network"
            "cpu"
            "memory"
            "disk"
            "battery"
          ];

          # ── Separator modules ──────────────────────────────────────
          # Right cap of the left pill
          "custom/sep-right" = {
            format  = sepRight;
            tooltip = false;
          };
          # Left cap of the center pill
          "custom/sep-left-c" = {
            format  = sepLeft;
            tooltip = false;
          };
          # Right cap of the center pill
          "custom/sep-right-c" = {
            format  = sepRight;
            tooltip = false;
          };
          # Left cap of the right pill
          "custom/sep-left" = {
            format  = sepLeft;
            tooltip = false;
          };

          # ── Content modules ────────────────────────────────────────
          "custom/power" = {
            format       = "";
            tooltip      = false;
            menu         = "on-click";
            menu-file    = "${config.home.homeDirectory}/.config/waybar/power_menu.xml";
            menu-actions = {
              shutdown  = "shutdown now";
              reboot    = "reboot";
              suspend   = "systemctl suspend";
              hibernate = "systemctl hibernate";
            };
          };

          "hyprland/workspaces" = {
            format       = "{icon}";
            sort-by      = "number";
            all-outputs  = true;
            format-icons = {
              "1"     = "󰲡";
              "2"     = "󰲣";
              "3"     = "󰲥";
              "4"     = "󰲧";
              "5"     = "󰲩";
              "6"     = "󰲫";
              "7"     = "󰲭";
              "8"     = "󰲯";
              "9"     = "󰲱";
              "10"    = "󰿭";
              active  = "";
              default = "";
              empty   = "";
            };
          };

          "clock" = {
            format     = " {:%H:%M}";
            format-alt = " {:%Y.%m.%d %H:%M}";
            tooltip    = false;
          };

          "network" = {
            format-wifi             = " ";
            format-ethernet         = "󰈁 ";
            format-disconnected     = "󰌙 ";
            tooltip-format-wifi     = "{essid} ({signalStrength}%)  | {ipaddr}";
            tooltip-format-ethernet = "{ifname} | {ipaddr}";
            tooltip-format          = "{ipaddr}";
          };

          "cpu" = {
            interval   = 1;
            format     = " {usage}%";
            min-length = 6;
            max-length = 6;
          };

          "memory" = {
            format = " {percentage}%";
          };

          "disk" = {
            interval = 60;
            format   = " {percentage_used}%";
            path     = "/";
          };

          "battery" = {
            interval = 60;
            states = {
              good     = 95;
              warning  = 20;
              critical = 10;
            };
            format         = "{icon} {capacity}%";
            format-plugged = "󰂄 {capacity}%";
            format-icons   = [ "󰁻" "󰁼" "󰁾" "󰂀" "󰂂" "󰁹" ];
          };
        };
      };

      style = ''
        /* ── Reset ─────────────────────────────────────────────────── */
        * {
          border:        none;
          border-radius: 0;
          margin:        0;
          padding:       0;
          font-weight:   700;
          color:         @base05;
        }

        /* Stylix prepends a * block setting "Hack Nerd Font Mono" + 11pt.
           Override with higher-specificity selectors to get the proportional
           variant (needed for full Nerd Font glyph coverage) at our size.  */
        window#waybar,
        window#waybar * {
          font-family: "Hack Nerd Font";
          font-size:   14px;
        }

        window#waybar {
          background: transparent;
        }

        /* ── Pill backgrounds ───────────────────────────────────────── */
        /* The three pill groups each get @base01 background. */
        .modules-left,
        .modules-center,
        .modules-right {
          background: transparent;
        }

        /* Inner content background on all non-separator modules */
        #custom-power,
        #workspaces,
        #clock,
        #network,
        #cpu,
        #memory,
        #disk,
        #battery {
          background: @base01;
          min-height: 32px;
        }

        /* ── Separator caps ─────────────────────────────────────────── */
        /* All separators: transparent bg, pill-colour fg, large font   */
        /* so the glyph fills the full bar height.                       */
        #custom-sep-right,
        #custom-sep-left,
        #custom-sep-left-c,
        #custom-sep-right-c {
          font-size:  32px;
          min-height: 32px;
          padding:    0;
          background: transparent;
          color:      @base01;
        }

        /* Right cap of left pill — pill bg behind it, transparent after */
        #custom-sep-right {
          background: @base01; /* left side is pill */
        }

        /* Left cap of right pill — transparent before, pill bg behind */
        #custom-sep-left {
          background: transparent; /* right side is pill — GTK renders right-to-left here */
        }

        /* Center pill caps: transparent on outside, pill bg on inside  */
        #custom-sep-left-c {
          background: transparent;
        }

        #custom-sep-right-c {
          background: @base01;
        }

        /* ── Module padding ─────────────────────────────────────────── */
        #custom-power {
          padding: 0 10px;
          border-radius: 0;
        }

        #clock {
          padding: 0 12px;
        }

        #network,
        #cpu,
        #memory,
        #disk,
        #battery {
          padding: 0 8px;
        }

        /* ── Workspaces ─────────────────────────────────────────────── */
        #workspaces {
          padding: 0 4px;
        }

        #workspaces button {
          padding:    0 5px;
          color:      @base04;
          background: transparent;
        }

        #workspaces button.active {
          color: @base0D;
        }

        #workspaces button.urgent {
          color: @base08;
        }

        #workspaces button:hover {
          background: transparent;
          color:      @base06;
        }

        /* ── State colours ──────────────────────────────────────────── */
        #battery.warning  { color: @base0A; }
        #battery.critical { color: @base08; }
        #cpu.warning      { color: @base0A; }
        #cpu.critical     { color: @base08; }
        #memory.warning   { color: @base0A; }
        #memory.critical  { color: @base08; }

        /* ── Tooltips ───────────────────────────────────────────────── */
        tooltip {
          background:    @base01;
          border-radius: 8px;
          color:         @base05;
        }

        tooltip label {
          padding: 4px 10px;
          color:   @base05;
        }

        /* ── Power menu ─────────────────────────────────────────────── */
        menu {
          background:    @base01;
          border-radius: 8px;
          color:         @base05;
          font-weight:   700;
        }

        menu > * {
          padding: 4px 12px;
        }

        menu > *:hover {
          background:    @base02;
          border-radius: 6px;
        }
      '';
    };
  };
}
