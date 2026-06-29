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
      confirm = true;
      backspace = "indent,eol,start";
      splitbelow = true;
      splitright = true;
      wrap = true;
      linebreak = true;
      breakindent = true;
      virtualedit = "block";
      spelllang = "en_us,da";
      updatetime = 500;
      ignorecase = true;
      smartcase = true;
      incsearch = true;
      hlsearch = true;

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
      laststatus = 2;
      numberwidth = 4;
      showmode = false;
      fillchars = "fold:-";
      foldlevelstart = 1;
      foldlevel = 1;

      # Files
      filetype = "on";
      undofile = true;
      undolevels = 256;
      backup = true;
      backupdir = "${config.xdg.cacheHome}/nvim/backup//";
      undodir = "${config.xdg.stateHome}/nvim/undo//";

      # Command-line completion
      wildmode = "longest,list,full";
      wildignorecase = true;
      wildignore = lib.concatStringsSep "," [
        "*.py[co]"
        "*.o"
        "*.obj"
        "*.bin"
        "*.dll"
        "*.exe"
        "*/.git/*"
        "*/.svn/*"
        "*/__pycache__/*"
        "*/build/**"
        "*.jpg"
        "*.png"
        "*.jpeg"
        "*.gif"
        "*.bmp"
        "*.tiff"
        "*.DS_Store"
        "*.aux"
        "*.bbl"
        "*.blg"
        "*.brf"
        "*.fls"
        "*.fdb_latexmk"
        "*.synctex.gz"
        "*.pdf"
      ];
    };

    programs.nixvim.extraConfigVim = ''
      set formatoptions+=2n
    '';

    home.activation.createNixvimStateDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${lib.escapeShellArg "${config.xdg.cacheHome}/nvim/backup"}
      mkdir -p ${lib.escapeShellArg "${config.xdg.stateHome}/nvim/undo"}
    '';
  };
}
