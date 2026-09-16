# Evaluate with a consuming nixosConfigurations.<HOST> built by ApexOS mkHost.
# No activation: variants replace the host home module to exercise bundle defaults.
system:
let
  lib = system.pkgs.lib;
  username = system.config.userGlobals.username;
  homeFor = configuration: configuration.config.home-manager.users.${username};
  current = homeFor system;
  bundleHome =
    bundle:
    homeFor (
      system.extendModules {
        modules = [
          {
            home-manager.users = lib.mkForce {
              ${username} = {
                home.stateVersion = current.home.stateVersion;
                myHomeModules.${bundle}.enable = true;
              };
            };
          }
        ];
      }
    );
  desktop = bundleHome "desktop";
  laptop = bundleHome "laptop";
  changed = homeFor (
    system.extendModules {
      modules = [
        {
          home-manager.users.${username}.myHomeModules.guiPrograms.quickshell.iconSize = lib.mkForce (
            current.myHomeModules.guiPrograms.quickshell.iconSize + 1
          );
        }
      ];
    }
  );
  service = home: home.systemd.user.services.quickshell.Service;
  tracksConfig =
    home:
    lib.elem "APEX_QUICKSHELL_CONFIG=${home.programs.quickshell.configs.apex}" (service home)
    .Environment;
  usesQuickshell =
    home:
    home.myHomeModules.guiPrograms.quickshell.enable
    && home.programs.quickshell.enable
    && home.programs.quickshell.systemd.enable
    && !home.programs.waybar.enable
    && !(home.myHomeModules.guiPrograms ? waybar);
in
assert usesQuickshell desktop;
assert usesQuickshell laptop;
assert desktop.myHomeModules.guiPrograms.quickshell.noBattery;
assert desktop.myHomeModules.guiPrograms.quickshell.output == "";
assert !laptop.myHomeModules.guiPrograms.quickshell.noBattery;
assert laptop.myHomeModules.guiPrograms.quickshell.output == "eDP-1";
assert tracksConfig current && tracksConfig changed;
assert (service current).Environment != (service changed).Environment;
assert (service current).ExecStart == (service changed).ExecStart;
{
  desktopDefaults = "passed";
  laptopDefaults = "passed";
  configChangesUnit = "passed";
  stableShellCommand = (service current).ExecStart;
  serviceSwitching = current.systemd.user.startServices;
}
