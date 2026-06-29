{ config, lib, ... }:

{
  config = lib.mkIf config.myHomeModules.tuiPrograms.nixvim.enable {
    programs.nixvim.plugins.gitsigns = {
      enable = true;
      settings = {
        signcolumn = true;
        numhl = false;
        linehl = false;
        current_line_blame = false;
      };
    };
  };
}
