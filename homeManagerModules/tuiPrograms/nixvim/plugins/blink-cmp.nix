{ config, lib, ... }:

{
  config = lib.mkIf config.myHomeModules.tuiPrograms.nixvim.enable {
    programs.nixvim.plugins.blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        keymap = {
          preset = "none";
          "<Tab>" = [
            "select_next"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "fallback"
          ];
          "<CR>" = [
            "accept"
            "fallback"
          ];
          "<C-e>" = [ "hide" ];
        };

        sources.default = [
          "lsp"
          "path"
          "buffer"
        ];

        completion = {
          list.selection = {
            preselect = false;
            auto_insert = true;
          };
          documentation.auto_show = true;
        };
      };
    };
  };
}
