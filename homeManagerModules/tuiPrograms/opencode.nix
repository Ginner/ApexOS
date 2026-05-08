{ config, pkgs, lib, ... }:

{
  options.myHomeModules.tuiPrograms.opencode = {
    enable = lib.mkEnableOption "AI coding assistant";
  };

  config = lib.mkIf config.myHomeModules.tuiPrograms.opencode.enable {
    programs.opencode = {
      enable = true;
      # TODO: Remove tui.theme once stylix gains an opencode target module.
      # Context: opencode v1.2.15+ moved TUI settings (theme, keybinds) out of
      # config.json into a separate tui.json. The HM programs.opencode module now
      # manages tui.json via programs.opencode.tui. Stylix's opencode target still
      # sets programs.opencode.settings.theme (the old location), so it does not
      # yet theme opencode. Until stylix is fixed (see nix-community/stylix#2264),
      # we set tui.theme here to use opencode's own built-in "stylix" theme and to
      # give HM ownership of tui.json, preventing activation conflicts.
      tui.theme = "stylix";
      settings = {
        plugin = [
          "@ex-machina/opencode-anthropic-auth@1.8.0"
        ];
        permission = {
          "*" = "ask";
        };
      };
    };
  };
}
