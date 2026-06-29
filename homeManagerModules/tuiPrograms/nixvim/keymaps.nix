{ config, lib, ... }:

{
  config = lib.mkIf config.myHomeModules.tuiPrograms.nixvim.enable {
    programs.nixvim.keymaps = [
      {
        action = "<cmd>Telescope live_grep<CR>";
        key = "<leader>g";
      }
      {
        action = "<cmd>Telescope find_files<CR>";
        key = "<leader>ff";
      }
      {
        action = "<cmd>UndotreeToggle<CR>";
        key = "<leader>u";
        mode = "n";
      }
      {
        action = "<cmd>bnext<CR>";
        key = "gb";
        mode = "n";
      }
      {
        action = "<cmd>bprevious<CR>";
        key = "gB";
        mode = "n";
      }
      {
        action = "<C-^>";
        key = "<leader>bb";
        mode = "n";
      }
      {
        action = "<C-w>h";
        key = "<C-h>";
        mode = "n";
      }
      {
        action = "<C-w>j";
        key = "<C-j>";
        mode = "n";
      }
      {
        action = "<C-w>k";
        key = "<C-k>";
        mode = "n";
      }
      {
        action = "<C-w>l";
        key = "<C-l>";
        mode = "n";
      }
      {
        action = "nzzzv";
        key = "n";
        mode = "n";
      }
      {
        action = "Nzzzv";
        key = "N";
        mode = "n";
      }
      {
        action = "mzJ`z";
        key = "J";
        mode = "n";
      }
      {
        action = "`[v`]";
        key = "gV";
        mode = "n";
      }
      {
        action = ":m '>+1<CR>gv=gv";
        key = "J";
        mode = "v";
      }
      {
        action = ":m '<-2<CR>gv=gv";
        key = "K";
        mode = "v";
      }
      {
        action = "<cmd>m .+1<CR>==";
        key = "<leader>j";
        mode = "n";
      }
      {
        action = "<cmd>m .-2<CR>==";
        key = "<leader>k";
        mode = "n";
      }
      {
        action = ''"=strftime("%Y.%m.%d")<CR>P'';
        key = "<F6>";
        mode = "n";
      }
      {
        action = ''<C-R>=strftime("%Y.%m.%d")<CR>'';
        key = "<F6>";
        mode = "i";
      }
      {
        action = "<cmd>setlocal spell! spelllang=en_us<CR>";
        key = "<F7>";
      }
      {
        action = "<cmd>setlocal spell! spelllang=da<CR>";
        key = "<F8>";
      }
      {
        action = ''(v:count > 5 ? "m'" . v:count : "") . "j"'';
        key = "j";
        mode = "n";
        options.expr = true;
      }
      {
        action = ''(v:count > 5 ? "m'" . v:count : "") . "k"'';
        key = "k";
        mode = "n";
        options.expr = true;
      }
      {
        action = "*``cgn";
        key = "cn";
        mode = "n";
      }
      {
        action = "*``cgN";
        key = "cN";
        mode = "n";
      }
      {
        action = "<cmd>tabnew<CR>";
        key = "<leader>tn";
        mode = "n";
      }
      {
        action = "<cmd>tabclose<CR>";
        key = "<leader>tc";
        mode = "n";
      }
      {
        action = "1gt";
        key = "<leader>1";
        mode = "n";
      }
      {
        action = "2gt";
        key = "<leader>2";
        mode = "n";
      }
      {
        action = "3gt";
        key = "<leader>3";
        mode = "n";
      }
      {
        action = "4gt";
        key = "<leader>4";
        mode = "n";
      }
      {
        action = "5gt";
        key = "<leader>5";
        mode = "n";
      }
      {
        action = "6gt";
        key = "<leader>6";
        mode = "n";
      }
      {
        action = "7gt";
        key = "<leader>7";
        mode = "n";
      }
      {
        action = "8gt";
        key = "<leader>8";
        mode = "n";
      }
      {
        action = "9gt";
        key = "<leader>9";
        mode = "n";
      }
      {
        action = "<C-w>w";
        key = "<leader><Tab>";
        mode = "n";
      }
      {
        action = "<C-w>v<C-w><Right>";
        key = "|";
        mode = "n";
      }
      {
        action = "<C-w>s<C-w><Down>";
        key = "-";
        mode = "n";
      }
      {
        action = ",<c-g>u";
        key = ",";
        mode = "i";
      }
      {
        action = ".<c-g>u";
        key = ".";
        mode = "i";
      }
      {
        action = "!<c-g>u";
        key = "!";
        mode = "i";
      }
      {
        action = "?<c-g>u";
        key = "?";
        mode = "i";
      }
    ];
  };
}
