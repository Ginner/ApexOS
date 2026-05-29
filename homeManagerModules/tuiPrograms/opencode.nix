{ config, pkgs, lib, ... }:

{
  options.myHomeModules.tuiPrograms.opencode = {
    enable = lib.mkEnableOption "AI coding assistant";
  };

  config = lib.mkIf config.myHomeModules.tuiPrograms.opencode.enable {
    programs.opencode = {
      enable = true;
      settings = {
        plugin = [
          "@ex-machina/opencode-anthropic-auth@1.8.1"
        ];
        permission = {
          "*" = "ask";
          read = "allow";
          grep = "allow";
          glob = "allow";
          todoread = "allow";
          todowrite = "allow";
          bash = {
            "*" = "ask";
            ls = "allow";
            "ls *" = "allow";
            cat = "allow";
            "cat *" = "allow";
            head = "allow";
            "head *" = "allow";
            tail = "allow";
            "tail *" = "allow";
            file = "allow";
            "file *" = "allow";
            wc = "allow";
            "wc *" = "allow";
            pwd = "allow";
            which = "allow";
            "which *" = "allow";
            "git status" = "allow";
            "git log" = "allow";
            "git log *" = "allow";
            "git diff" = "allow";
            "git diff *" = "allow";
            "git show" = "allow";
            "git show *" = "allow";
            "nix flake check *" = "allow";
            "nix eval *" = "allow";
          };
        };
      };
    };
  };
}
