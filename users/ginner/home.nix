{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Email toolchain — account definitions drive all config file generation.
  # Sops secret key names default to "<accountname>-address" etc.; override only
  # if your secrets/email.yaml uses different key names.
  # The sops YAML file contains: work-address, work-realname, work-password,
  #                               private-address, private-realname, private-password
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/email.yaml;
  };

  myHomeModules.services.email = {
    enable = true;
    accounts = {
      work = {
        primary = true;
        imapHost = "imap.startmail.com";
        smtpHost = "smtp.startmail.com";
        macroKey = "1";
      };
      private = {
        primary = false;
        imapHost = "imap.startmail.com";
        smtpHost = "smtp.startmail.com";
        macroKey = "2";
      };
    };
  };

  myHomeModules.tuiPrograms.neomutt.enable = true;
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
