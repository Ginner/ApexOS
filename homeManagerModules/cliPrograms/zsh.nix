{ config, lib, pkgs, ... }:

let
  cfg = config.myHomeModules.cliPrograms.zsh;
in
{
  options.myHomeModules.cliPrograms.zsh = {
    enable = lib.mkEnableOption "Zsh shell user configuration";

    enableAutosuggestions = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable zsh autosuggestions";
    };

    enableSyntaxHighlighting = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable zsh syntax highlighting";
    };

    enableCompletion = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable zsh completion";
    };

    enableAutocd = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable autocd in zsh";
    };

    dotDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/zsh";
      description = "Directory for zsh configuration files";
    };

    extraInit = lib.mkOption {
      type = lib.types.lines;
      default = ''
        setopt histverify
        setopt correct
        eval "$(direnv hook zsh)"
      '';
      description = "Extra initialization commands for zsh";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = cfg.enableAutosuggestions;
      syntaxHighlighting.enable = cfg.enableSyntaxHighlighting;
      enableCompletion = cfg.enableCompletion;
      completionInit = ''
        autoload -U compinit
        mkdir -p "${config.xdg.cacheHome}/zsh"
        compinit -d "${config.xdg.cacheHome}/zsh/zcompdump"
      '';
      autocd = cfg.enableAutocd;
      dotDir = cfg.dotDir;
      history = {
        ignoreDups = true;
        expireDuplicatesFirst = true;
        ignoreSpace = true;
        share = true;
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };
      shellAliases = {
        history = "history 1";
        ls = "eza";
        ll = "eza -l";
        lt = "eza -T";
        la = "eza -lah --group-directories-first";
        las = "eza -lah --group-directories-first --total-size";
        cal = "cal -wm";
        cp = "cp -riv";
        mv = "mv -iv";
        rm = "rm -I";
        mkdir = "mkdir -vp";
        ":q" = "exit";
      };
      initContent = cfg.extraInit;
    };

    # Enable kitty integration if kitty is enabled
    programs.kitty.shellIntegration.enableZshIntegration = lib.mkIf (config.myHomeModules.cliPrograms.kitty.enable or false) (lib.mkDefault true);
  };
}
