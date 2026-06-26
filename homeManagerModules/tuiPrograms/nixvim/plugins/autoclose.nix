{ config, lib, ... }:

{
  config = lib.mkIf config.myHomeModules.tuiPrograms.nixvim.enable {
    programs.nixvim.plugins.autoclose = {
      enable = true;
      settings = {
        keys = {
          "'" = {
            disabled_filetypes = [ "markdown" "latex" ];
          };
          "`" = {
            disabled_filetypes = [ "markdown" "latex" ];
          };
        };
      };
    };
  };
}
