{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myHomeModules.tuiPrograms.nixvim;
in

{
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.treesitter = {
      enable = true;
      grammarPackages =
        with pkgs.vimPlugins.nvim-treesitter.builtGrammars;
        [
          nix
          python
          html
          bash
          css
          javascript
          markdown
          json
        ]
        ++ lib.optionals cfg.latex.enable [
          latex
          bibtex
        ];
      settings = {
        indent.enable = true;
        autopairs.enable = true;
        textobjects = lib.mkIf cfg.latex.enable {
          select = {
            enable = true;
            lookahead = true;
            keymaps = {
              "aa" = "@parameter.outer";
              "ia" = "@parameter.inner";
              "af" = "@function.outer";
              "if" = "@function.inner";
              "ac" = "@class.outer";
              "ic" = "@class.inner";
            };
          };
          move = {
            enable = true;
            set_jumps = true;
            goto_next_start = {
              "]m" = "@function.outer";
              "]]" = "@class.outer";
            };
            goto_previous_start = {
              "[m" = "@function.outer";
              "[[" = "@class.outer";
            };
          };
        };
      };
      highlight = {
        enable = true;
        disable = lib.optionals cfg.latex.enable [ "latex" ];
      };
    };

    programs.nixvim.extraPlugins = lib.mkIf cfg.latex.enable [
      pkgs.vimPlugins.nvim-treesitter-textobjects
    ];
  };
}
