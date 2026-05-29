{ config, lib, ... }:

{
  options.myHomeModules.cleanup = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Remove files left behind by the initial pre-Home-Manager shell setup.";
    };
  };

  config = lib.mkIf config.myHomeModules.cleanup.enable {
    home.activation.cleanupBootstrapLeftovers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      zsh_cache_dir="${config.xdg.cacheHome}/zsh"
      zsh_history="${config.xdg.dataHome}/zsh/history"

      mkdir -p "$zsh_cache_dir" "$(dirname "$zsh_history")"

      if [ -f "${config.home.homeDirectory}/.config/zsh/.zcompdump" ] && [ ! -e "$zsh_cache_dir/zcompdump" ]; then
        mv "${config.home.homeDirectory}/.config/zsh/.zcompdump" "$zsh_cache_dir/zcompdump"
      fi

      if [ -f "${config.home.homeDirectory}/.zsh_history" ]; then
        cat "${config.home.homeDirectory}/.zsh_history" >> "$zsh_history"
        rm -f "${config.home.homeDirectory}/.zsh_history"
      fi

      rm -f "${config.home.homeDirectory}/.zcompdump" "${config.home.homeDirectory}/.config/zsh/.zcompdump"
      rm -rf "${config.home.homeDirectory}/.npm"
    '';
  };
}
