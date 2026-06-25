{ config, lib, ... }:

let
  cfg = config.myHomeModules.tuiPrograms.nixvim;
in

{
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.lsp = {
      enable = true;
      servers = {
        nixd.enable = true;
        marksman.enable = true;
        texlab = lib.mkIf cfg.latex.enable {
          enable = true;
          settings = {
            texlab = {
              build = {
                executable = "latexmk";
                args = [
                  "-xelatex"
                  "-interaction=nonstopmode"
                  "-synctex=1"
                  "-auxdir=${cfg.latex.auxDirectory}"
                  "%f"
                ];
                onSave = false;
                forwardSearchAfter = false;
              };
              forwardSearch.executable = "zathura";
            };
          };
        };
      };
    };
  };
}
