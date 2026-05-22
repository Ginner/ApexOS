{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myHomeModules.cliPrograms.ssh;
in
{
  options.myHomeModules.cliPrograms.ssh = {
    enable = lib.mkEnableOption "SSH client";

    enableControlMaster = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    settings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.anything);
      default = { };
      description = "Forwarded to programs.ssh.settings";
    };
    includes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "File globs forwarded to programs.ssh.includes (rendered as Include directives at the top of ~/.ssh/config, before any Host/Match blocks). Non-existent paths are silently ignored by ssh.";
    };
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      includes = cfg.includes;
      extraConfig = cfg.extraConfig;
      settings =
        cfg.settings
        // lib.optionalAttrs cfg.enableControlMaster {
          "*" = {
            ControlMaster = "auto";
            ControlPersist = "10m";
            ControlPath = "~/.ssh/cm-%C";
          };
        };
    };
  };
}
