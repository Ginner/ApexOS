{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myHomeModules.tuiPrograms.nixvim;
  latexCfg = cfg.latex;
in
{
  options.myHomeModules.tuiPrograms.nixvim.latex = {
    enable = lib.mkEnableOption "LaTeX editing support in NixVim";

    auxDirectory = lib.mkOption {
      type = lib.types.str;
      default = "aux";
      description = "Project-local directory for LaTeX auxiliary build files.";
    };
  };

  config = lib.mkMerge [
    {
      myHomeModules.tuiPrograms.nixvim.latex.enable =
        lib.mkDefault config.myHomeModules.cliPrograms.latex.enable;
    }

    (lib.mkIf (cfg.enable && latexCfg.enable) {
      programs.nixvim = {
        extraPlugins = with pkgs.vimPlugins; [
          vimtex
          tex-conceal-vim
        ];

        globals = {
          tex_flavor = "latex";

          vimtex_compiler_method = "latexmk";
          vimtex_view_method = "zathura";
          vimtex_complete_close_braces = 1;
          vimtex_quickfix_open_on_warning = 1;
          vimtex_complete_enabled = 0;
          vimtex_fold_enabled = 0;

          vimtex_compiler_latexmk = {
            callback = 1;
            continuous = 1;
            executable = "latexmk";
            hooks = [ ];
            options = [
              "-verbose"
              "-file-line-error"
              "-synctex=1"
              "-interaction=nonstopmode"
              "-auxdir=${latexCfg.auxDirectory}"
            ];
          };

          vimtex_compiler_latexmk_engines = {
            "_" = "-xelatex";
            pdflatex = "-pdf";
            dvipdfex = "-pdfdvi";
            lualatex = "-lualatex";
            xelatex = "-xelatex";
            "context (pdftex)" = "-pdf -pdflatex=texexec";
            "context (luatex)" = "-pdf -pdflatex=context";
            "context (xetex)" = "-pdf -pdflatex='texexec --xtx'";
          };
        };

        autoGroups.texgrp.clear = true;
        autoCmd = [
          {
            desc = "Treat .tex files as LaTeX";
            event = [
              "BufRead"
              "BufNewFile"
            ];
            pattern = [ "*.tex" ];
            command = "set filetype=tex";
            group = "texgrp";
          }
          {
            desc = "Use two-space indentation and soft wrapping for LaTeX";
            event = [
              "BufRead"
              "BufNewFile"
            ];
            pattern = [ "*.tex" ];
            command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2 wrap linebreak nolist";
            group = "texgrp";
          }
        ];
      };
    })
  ];
}
