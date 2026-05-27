{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Email secrets stay in this host-specific repo; ApexMail only consumes values.
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/email.yaml;
  };

  sops.secrets = {
    "work-address" = { };
    "work-realname" = { };
    "work-password" = { };
    "work-neomutt-extra-config" = { };
    "private-address" = { };
    "private-realname" = { };
    "private-password" = { };
    "private-neomutt-extra-config" = { };
  };

  apexMail = {
    enable = true;
    renderBackend = "sops";
    accounts = {
      work = {
        primary = true;
        provider = "startmail";
        folderPreset = "startmail";
        macroKey = "1";
        address = "work-address";
        realname = "work-realname";
        passwordCommand = "cat ${config.sops.secrets."work-password".path}";
        extraNeomuttConfig = "work-neomutt-extra-config";
      };
      private = {
        primary = false;
        provider = "startmail";
        folderPreset = "startmail";
        macroKey = "2";
        address = "private-address";
        realname = "private-realname";
        passwordCommand = "cat ${config.sops.secrets."private-password".path}";
        extraNeomuttConfig = "private-neomutt-extra-config";
      };
    };
  };

  myHomeModules.tuiPrograms.khard.enable = true;

  # Git identity
  programs.git.settings.user = {
    name = "Ginner";
    email = "26798615+Ginner@users.noreply.github.com";
  };

  # SSH match blocks
  myHomeModules.cliPrograms.ssh = {
    enable = true;
    # Optional user-supplied file for host entries that should not live in the
    # repo (e.g. private IPs). Create ~/.ssh/extra_hosts with standard ssh_config
    # Host blocks. If the file is absent ssh silently ignores the Include.
    includes = [ "~/.ssh/extra_hosts" ];
    settings = {
      "github.com" = {
        User = "git";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "forgejo" = {
        HostName = "forgejo.ginnerskov.co";
        User = "git";
        Port = 222;
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "codeberg" = {
        User = "git";
        HostName = "codeberg.org";
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "AMEE" = {
        User = "ginner";
        HostName = "100.64.0.1";
        Port = 2248;
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "GLaDOS" = {
        User = "ginner";
        HostName = "100.64.0.5";
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
