
| program                                           | default | server | desktop | laptop | nm | hmm | notes                                                                |
|---------------------------------------------------|:-------:|:------:|:-------:|:------:|:--:|:---:|----------------------------------------------------------------------|
| fwupd                                             |         |        |    X    |    X   |  X |     | Firmware updates for hardware.                                       |
| bolt                                              |         |        |         |    X   |  X |     | Thunderbolt security (auto-detects TB), fixes TB on my X13.          |
| usbutils                                          |         |   X*   |    X*   |   X*   |  X |     | `lsusb`—moved to nixos for udev rules.                               |
| greetd                                            |         |        |    X    |    X   |  X |     | Display/login manager.                                               |
| pipewire                                          |         |        |    X    |    X   |  X |     | Include `wireplumber` & portals via system.                          |
| tlp                                               |         |        |         |    X   |  X |     | Power management for laptops.                                        |
| tailscale (daemon)                                |         |    X   |    X*   |   X*   |  X |     | Overlay network. Daemon + firewall                                   |
| brightnessctl                                     |         |        |    X    |    X   |  X |     | Control screen brightness.                                           |
| xremap                                            |         |        |    X*   |   X*   |  X |     | Key remapping service.                                               |
| openssh (daemon)                                  |    X    |    X   |    X*   |   X*   |  X |     | Server/service side (separate from client cfg).                      |
| zsh (binary & default shell)                      |    X    |   X*   |    X*   |   X*   |  X |  X  | System sets default shell; HM handles per-user rc/plugins.           |
| neovim                                            |    X    |    X   |    X    |    X   |  X |  X  | System provides binary + minimal defaults; HM layers nixvim configs. |
| hyprland (WM)                                     |         |        |    X    |    X   |  X |  X  | HM manages WM config; system handles greeter/portals.                |
| stylix                                            |         |        |    X    |    X   |  X |  X  | Cross-cuts system + HM theming. Uses rose-pine-hyprcursor.           |
| kitty                                             |         |        |    X    |    X   |    |  X  | Terminal is per-user.                                                |
| mako                                              |         |        |    X    |    X   |    |  X  | Wayland notifications—user service (handle with AGS instead?).       |
| quickshell                                        |         |        |    X    |    X   |    |  X  | ApexOS status bar, managed as a user service.                        |
| ags                                               |         |        |    X*   |   X*   |    |  X  | For Wayland desktop bar/shell (Use Astal directly instead?).         |
| wl-clipboard                                      |         |        |    X    |    X   |    |  X  | Wayland clipboard.  (via wayland-tools)                              |
| grim / slurp / wf-recorder / swappy               |         |        |    X    |    X   |    |  X  | Wayland screenshots/recording—user tools.  (via wayland-tools)       |
| walker                                            |         |        |    X    |    X   |    |  X  | Launcher.                                                            |
| firefox                                           |         |        |    X    |    X   |    |  X  | Browser (look into Zen-browser?).                                    |
| inkscape                                          |         |        |    X*   |   X*   |    |  X  | GUI app.                                                             |
| sxiv                                              |         |        |    X*   |   X*   |    |  X  | Image viewer (feh?, imv?, vimiv? Latter 2 has wayland support).      |
| mpv                                               |         |        |    X*   |   X*   |    |  X  | Media player.                                                        |
| zathura                                           |         |        |    X    |    X   |    |  X  | PDF viewer.                                                          |
| kde-connect                                       |         |        |    X*   |   X*   |  X |  X  | HM runs user service; system opens firewall ports.                   |
| cups (printing)                                   |         |        |    X*   |   X*   |  X |     | CUPS + Avahi mDNS discovery; managed at :631 web UI. Off by default.  |
| sane (scanning)                                   |         |        |    X*   |   X*   |  X |     | SANE + sane-airscan driverless scanning. Off by default.             |
| git (client)                                      |    X    |    X   |    X    |    X   |    |  X  | Per-user config in HM (`user.name`, signing, etc.).                  |
| ssh (client)                                      |    X    |    X   |    X    |    X   |    |  X  | Per-user keys and `~/.ssh/config` via HM.                            |
| direnv                                            |         |        |    X    |    X   |    |  X  | Load/Unload env vars.                                                |
| tmux                                              |         |    X   |         |        |    |  X  | Terminal multiplexer, used for ssh sessions.                         |
| starship                                          |         |        |    X    |    X   |    |  X  | Fancy shell Prompt, might delete later, idk.                         |
| bat / eza / fd / ripgrep / fzf / jq / wget / tree |         |        |    X    |    X   |    |  X  | Core CLI set; HM is ideal.  (via cli-tools)                          |
| yazi                                              |         |        |    X*   |   X*   |    |  X  | TUI file manager.                                                    |
| btop                                              |         |        |    X*   |   X*   |    |  X  | Monitoring tool (Glances for servers? Maybe in general?).            |
| imagemagick / poppler                             |         |        |    X    |    X   |    |  X  | Useful iamge tooling.  (as packages)                                 |
| ffmpeg / ffmpegthumbnailer                        |         |        |    X    |    X   |    |  X  | Media tooling; thumbnailer supports file managers.  (as packages)    |
| zip / unzip / xz / p7zip                          |         |    X   |    X    |    X   |    |  X  | Archive tools.  (via archive-tools)                                  |
| ncspot                                            |         |        |    X*   |   X*   |    |  X  | Spotify TUI, we shouldn't use Spotify though, bastards.              |
| newsboat                                          |         |        |    X*   |   X*   |    |  X  | RSS reader.                                                          |
| calcurse                                          |         |        |    X*   |   X*   |    |  X  | Calendar TUI.                                                        |
| khard                                             |         |        |    X*   |   X*   |    |  X  | Contacts TUI, is it really better than abook?                        |
| cheat                                             |         |        |    X*   |   X*   |    |  X  | Cheat sheets. Use in conjunction w. tealdeer?                        |
| LaTeX (texlive)                                   |         |        |    X*   |   X*   |    |  X  | Big footprint, off by default.                                       |
| podman (engine)                                   |         |   X*   |         |        |  X |     | System sets cgroups, subuids; CLI can be added via HM.               |
| numbat                                            |         |        |    X*   |   X*   |    |  X  | Calculator.                                                          |

Legend: X = recommended, X* = optional/role-dependent, HM = Home-Manager.
