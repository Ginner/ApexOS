{ config, lib, ... }:

{
  config = lib.mkIf config.myHomeModules.tuiPrograms.nixvim.enable {
    programs.nixvim.autoGroups = {
      lastplacegrp.clear = true;
      mymdgrp.clear = true;
      pygrp.clear = true;
      wikigrp.clear = true;
    };
    programs.nixvim.autoCmd = [
      {
        desc = "Restore cursor from local lastplace mark";
        event = [ "VimEnter" ];
        pattern = [ "*" ];
        command = ''if line("'z") > 1 && line("'z") <= line("$") | normal! g'z | endif'';
        group = "lastplacegrp";
      }
      {
        desc = "Save cursor to local lastplace mark";
        event = [ "BufLeave" "VimLeavePre" ];
        pattern = [ "*" ];
        command = "normal! mz";
        group = "lastplacegrp";
      }

      {
        command = "setlocal autowriteall";
        event = [ "FileType" "BufRead" ];
        pattern = [ "markdown" "*.md" "*.markdown" ];
        group = "mymdgrp";
      }
      {
        desc = "Save the buffer when leaving (e.g. following links in wiki)";
        command = "silent! wall";
        event = [ "BufLeave" ];
        pattern = [ "markdown" "*.md" "*.markdown" ];
        group = "mymdgrp";
      }
      {
        desc = "Use Python indentation and line length defaults";
        command = "setlocal tabstop=4 softtabstop=4 shiftwidth=4 textwidth=119 colorcolumn=120 expandtab autoindent fileformat=unix";
        event = [ "BufRead" "BufNewFile" ];
        pattern = [ "*.py" ];
        group = "pygrp";
      }
      {
        desc = "Vertically center the buffer when entering insert mode";
        command = "norm zz";
        event = [ "InsertEnter" ];
        pattern = [ "*" ];
      }
      {
        desc = "Remove trailing whitespace before writing files";
        command = "%s/\s\+$//e";
        event = [ "BufWritePre" ];
        pattern = [ "*" ];
      }
    ];

    programs.nixvim.extraConfigVim = ''
      command! -nargs=* Wrap set wrap linebreak nolist
      command! Q q
      command! W w
      command! Right execute "normal! hv0d:right\<CR>0gvp"
    '';
  };
}
