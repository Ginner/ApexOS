{ config, lib, ... }:

{
  config = lib.mkIf config.myHomeModules.tuiPrograms.nixvim.enable {
    programs.nixvim.opts = {
      # Editor
      relativenumber = true;
      number = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 5;
      showcmd = true;
      cmdheight = 0;
      conceallevel = 2;
      ignorecase = true;
      smartcase = true;

      # Tab & indentation
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;
      autoindent = true;
      smartindent = true;
      smarttab = true;

      # Macros
      lazyredraw = true;

      # Syntax
      showmatch = true;

      # Files
      filetype = "on";
    };
  };
}
