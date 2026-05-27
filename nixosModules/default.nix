{ config, pkgs, lib, ... }:

let
  user = config.userGlobals.username;
in
{
  imports = [
    # Service modules (via services/default.nix)
    ./services

    # Program modules (via programs/default.nix)
    ./programs

    # Shared modules
    ./shared/stylix.nix

    # Bundle modules
    ./laptop.nix
    ./desktop.nix
    ./server.nix
  ];

  options.userGlobals = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "The username for the default user.";
    };
  };

  options.myModules = {
    # Global options that apply to all systems
    default = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable default system configuration";
      };
    };
    # Another way of creating an enable option
    home-manager = {
      enable = lib.mkEnableOption "Enable home-manager";
    };
  };

  config = lib.mkIf config.myModules.default.enable {
    # Default configurations for all systems
    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
        trusted-users = [ "root" "@wheel" ];
      };
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    time.timeZone = lib.mkDefault "Europe/Copenhagen";
    i18n.defaultLocale = lib.mkDefault "da_DK.UTF-8";
    i18n.extraLocaleSettings = {
      LANG = lib.mkDefault "en_DK.UTF-8";
    };
    console = {
      font = lib.mkDefault "Lat2-Terminus16";
      keyMap = lib.mkDefault "dk";
    };

    # Default packages for all systems - minimal core only
    environment.systemPackages = with pkgs; [
      file
      which
      lm_sensors
      nixfmt
    ];

    # Enable basic services that apply to all systems
    myModules.services.openssh.enable = lib.mkDefault true;

    # Basic security
    security.sudo.wheelNeedsPassword = true;

    # System provides neovim binary + minimal defaults
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    # Enable zsh system-wide (user configs handled by HM)
    myModules.programs.zsh.enable = lib.mkDefault true;
  };

}
