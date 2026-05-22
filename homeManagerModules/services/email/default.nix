{
  config,
  pkgs,
  lib,
  ...
}:

# Email toolchain module — mbsync, msmtp, notmuch, and per-account sops templates.
#
# ## Secret vs PII policy
# - Secrets (passwords, API keys): must not appear in version control OR the Nix store.
#   These are stored in sops-encrypted YAML and injected at activation time via sops templates.
# - PII (email addresses, real names): must not appear in version control,
#   but the Nix store is acceptable. These are also sourced from sops secrets and
#   injected via sops templates — not because they need to be hidden from the store,
#   but because they must not be hardcoded in committed files.
#
# ## User-facing configuration
# Users should only need to touch:
#   hosts/<hostname>/configuration.nix
#   hosts/<hostname>/home.nix
#   users/<username>/home.nix
#
# To use this module, a user sets in their home.nix:
#
#   sops.defaultSopsFile = ../../secrets/email.yaml;  # encrypted, safe to commit
#   myHomeModules.services.email.enable = true;
#   myHomeModules.services.email.accounts = {
#     work = {
#       primary = true;
#       imapHost = "imap.example.com";
#       smtpHost = "smtp.example.com";
#       # Optional: override sops key names if yours differ from the defaults
#       # addressSecret  = "work-address";   # default: "<name>-address"
#       # realnameSecret = "work-realname";  # default: "<name>-realname"
#       # passwordSecret = "work-password";   # default: "<name>-password"
#     };
#   };
#
# The sops YAML file must contain keys matching the secret names above.
# Default key names for an account named "work":
#   work-address, work-realname, work-password
#
# ## Generated files (via sops templates, written at activation)
# - ~/.config/isyncrc            — mbsync config, one IMAPAccount/Store/Channel per account
# - ~/.config/msmtp/config       — msmtp config, one account stanza per account
# - ~/.config/neomutt/<name>     — per-account neomutt identity file
# - ~/.config/notmuch/default/config — notmuch config using primary account address

let
  cfg = config.myHomeModules.services.email;

  # Sorted account list: primary first, then rest alphabetically
  accountList =
    let
      primary = lib.filter (a: a.primary) (lib.attrValues cfg.accounts);
      others = lib.filter (a: !a.primary) (lib.attrValues cfg.accounts);
    in
    primary ++ (lib.sortOn (a: a.name) others);

  primaryAccount = lib.findFirst (a: a.primary) null accountList;

  # Resolve an account's sops placeholder by its secret key name
  ph = secretKey: config.sops.placeholder.${secretKey};

  secretPath = secretKey: config.sops.secrets.${secretKey}.path;

  concatStanzas = f: xs: lib.concatStringsSep "\n" (map f xs);

  # Generate the isyncrc store stanzas for one account. This follows the syntax
  # from the previous working mbsyncrc; notably, "Subfolders" is case-sensitive.
  mkIsyncStores = a: ''
    IMAPStore ${a.name}-remote
    Host ${a.imapHost}
    Port ${toString a.imapPort}
    User ${ph a.addressSecret}
    PassCmd "cat ${secretPath a.passwordSecret}"
    AuthMechs LOGIN
    TLSType IMAPS
    CertificateFile /etc/ssl/certs/ca-certificates.crt

    MaildirStore ${a.name}-local
    Subfolders Verbatim
    Path ${config.xdg.dataHome}/mail/${a.name}/
    Inbox ${config.xdg.dataHome}/mail/${a.name}/INBOX
  '';

  # Generate the isyncrc channel stanza for one account. Channels are emitted
  # after all stores because this isync parser does not allow later stores once
  # it has entered a Channel section.
  mkIsyncChannel = a: ''
    Channel ${a.name}
    Expunge Both
    Far :${a.name}-remote:
    Near :${a.name}-local:
    Patterns ${lib.concatStringsSep " " a.mbsyncPatterns}
    Create Both
    SyncState *
    MaxMessages 0
    ExpireUnread no
  '';

  # Generate the msmtp stanza for one account
  mkMsmtpStanza = a: ''
    account ${a.name}
    auth on
    from ${ph a.addressSecret}
    host ${a.smtpHost}
    passwordeval cat ${secretPath a.passwordSecret}
    port ${toString a.smtpPort}
    tls on
    tls_starttls off
    tls_trust_file /etc/ssl/certs/ca-certificates.crt
    user ${ph a.addressSecret}
  '';

  # Generate the neomutt per-account identity file for one account
  mkNeomuttAccountFile = a: ''
    set ssl_force_tls = yes
    set certificate_file=/etc/ssl/certs/ca-certificates.crt

    # GPG section
    set crypt_autosign = no
    set crypt_opportunistic_encrypt = no
    set pgp_use_gpg_agent = yes
    set mbox_type = Maildir
    set sort = "threads"

    # MTA section
    set sendmail='msmtpq --read-envelope-from --read-recipients'

    # Sidebar
    set sidebar_visible = yes
    set sidebar_short_path = yes
    set sidebar_width = 28
    set sidebar_format = '%D%* %?F? %F? %?N?%N/?%?S?%S?'

    # MRA section
    set folder='${config.xdg.dataHome}/mail/${a.name}'
    set from='${ph a.addressSecret}'
    set postponed='+${a.draftsFolder}'
    set realname='${ph a.realnameSecret}'
    set record='+${a.sentFolder}'
    set spoolfile='+INBOX'
    set trash='+${a.trashFolder}'

    macro index,pager gi "<change-folder>=INBOX<enter>" "go to inbox"
    macro index,pager Mi ";<save-message>=INBOX<enter>" "move mail to inbox"
    macro index,pager Ci ";<copy-message>=INBOX<enter>" "copy mail to inbox"
    macro index,pager gd "<change-folder>=${a.draftsFolder}<enter>" "go to drafts"
    macro index,pager Md ";<save-message>=${a.draftsFolder}<enter>" "move mail to drafts"
    macro index,pager Cd ";<copy-message>=${a.draftsFolder}<enter>" "copy mail to drafts"
    macro index,pager gj "<change-folder>=${a.spamFolder}<enter>" "go to junk"
    macro index,pager Mj ";<save-message>=${a.spamFolder}<enter>" "move mail to junk"
    macro index,pager Cj ";<copy-message>=${a.spamFolder}<enter>" "copy mail to junk"
    macro index,pager gt "<change-folder>=${a.trashFolder}<enter>" "go to trash"
    macro index,pager Mt ";<save-message>=${a.trashFolder}<enter>" "move mail to trash"
    macro index,pager Ct ";<copy-message>=${a.trashFolder}<enter>" "copy mail to trash"
    macro index,pager gs "<change-folder>=${a.sentFolder}<enter>" "go to sent"
    macro index,pager Ms ";<save-message>=${a.sentFolder}<enter>" "move mail to sent"
    macro index,pager Cs ";<copy-message>=${a.sentFolder}<enter>" "copy mail to sent"
    macro index,pager ga "<change-folder>=${a.archiveFolder}<enter>" "go to archive"
    macro index,pager Ma ";<save-message>=${a.archiveFolder}<enter>" "move mail to archive"
    macro index,pager Ca ";<copy-message>=${a.archiveFolder}<enter>" "copy mail to archive"

    unset signature

    # notmuch section
    set nm_default_uri = "notmuch://${config.xdg.dataHome}/mail"
    virtual-mailboxes "My INBOX" "notmuch://?query=tag%3Ainbox"

    ${lib.optionalString (a.extraNeomuttConfigSecret != null) (ph a.extraNeomuttConfigSecret)}
  '';

in
{
  options.myHomeModules.services.email = {
    enable = lib.mkEnableOption "email toolchain (mbsync, msmtp, notmuch, neomutt account files)";

    accounts = lib.mkOption {
      default = { };
      description = ''
        Attrset of email accounts. Each key is the account name (used as maildir
        subdirectory name, msmtp account name, and neomutt source file name).
        Exactly one account must have primary = true.
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Account name (derived from attrset key).";
              };

              primary = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Mark this as the primary account (exactly one must be true).";
              };

              imapHost = lib.mkOption {
                type = lib.types.str;
                description = "IMAP server hostname.";
              };

              imapPort = lib.mkOption {
                type = lib.types.int;
                default = 993;
                description = "IMAP port (default 993, IMAPS).";
              };

              smtpHost = lib.mkOption {
                type = lib.types.str;
                description = "SMTP server hostname.";
              };

              smtpPort = lib.mkOption {
                type = lib.types.int;
                default = 465;
                description = "SMTP port (default 465, TLS).";
              };

              mbsyncPatterns = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [
                  "*"
                  "!Spam"
                ];
                description = "mbsync channel Patterns — folders to sync.";
              };

              archiveFolder = lib.mkOption {
                type = lib.types.str;
                default = "Archive";
                description = "Archive folder name for neomutt macros.";
              };

              draftsFolder = lib.mkOption {
                type = lib.types.str;
                default = "Drafts";
                description = "Drafts folder name for neomutt postponed messages and macros.";
              };

              sentFolder = lib.mkOption {
                type = lib.types.str;
                default = "Sent";
                description = "Sent folder name for neomutt record and macros.";
              };

              trashFolder = lib.mkOption {
                type = lib.types.str;
                default = "Trash";
                description = "Trash folder name for neomutt trash and macros.";
              };

              spamFolder = lib.mkOption {
                type = lib.types.str;
                default = "Junk";
                description = "Spam/junk folder name for neomutt macros.";
              };

              macroKey = lib.mkOption {
                type = lib.types.str;
                description = ''
                  Neomutt account-switching macro key (e.g. "1" for i1, "2" for i2).
                  Assign unique keys across all accounts.
                '';
              };

              # Sops secret key names — default to "<accountname>-<field>"
              addressSecret = lib.mkOption {
                type = lib.types.str;
                default = "${name}-address";
                description = "Key name in the sops YAML for this account's email address.";
              };

              realnameSecret = lib.mkOption {
                type = lib.types.str;
                default = "${name}-realname";
                description = "Key name in the sops YAML for this account's display name.";
              };

              passwordSecret = lib.mkOption {
                type = lib.types.str;
                default = "${name}-password";
                description = "Key name in the sops YAML for this account's password or app password.";
              };

              extraNeomuttConfigSecret = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Optional key name in the sops YAML containing extra neomutt config for this account.";
              };
            };
          }
        )
      );
    };
  };

  config = lib.mkIf cfg.enable {

    assertions = [
      {
        assertion = (lib.length (lib.filter (a: a.primary) (lib.attrValues cfg.accounts))) == 1;
        message = "myHomeModules.services.email: exactly one account must have primary = true.";
      }
    ];

    # Install binaries only — do NOT use programs.mbsync.enable or programs.msmtp.enable.
    # Those options cause HM to manage ~/.config/isyncrc and ~/.config/msmtp/config
    # respectively, which conflicts with sops.templates owning those exact paths.
    # Installing via home.packages gives us the binaries without HM touching the configs.
    # msmtpq is bundled inside the msmtp package (no separate derivation needed).
    # notmuch is also here to avoid HM's assertion on user.primaryEmail.
    # All three config files are written by sops templates below.
    home.packages = with pkgs; [
      isync
      msmtp
      notmuch
    ];

    # Declare all sops secrets derived from account definitions
    sops.secrets = lib.mkMerge (
      map (
        a:
        {
          ${a.addressSecret} = { };
          ${a.realnameSecret} = { };
          ${a.passwordSecret} = { };
        }
        // lib.optionalAttrs (a.extraNeomuttConfigSecret != null) {
          ${a.extraNeomuttConfigSecret} = { };
        }
      ) accountList
    );

    # All sops templates in one assignment to avoid duplicate attribute errors.
    sops.templates = lib.mkMerge [
      # mbsync config — one stanza per account
      {
        "isyncrc" = {
          path = "${config.xdg.configHome}/isyncrc";
          content =
            (concatStanzas mkIsyncStores accountList) + "\n" + (concatStanzas mkIsyncChannel accountList);
        };
      }

      # msmtp config — one stanza per account, default = primary
      {
        "msmtp-config" = {
          path = "${config.xdg.configHome}/msmtp/config";
          content =
            (lib.concatMapStrings mkMsmtpStanza accountList) + "\naccount default : ${primaryAccount.name}\n";
        };
      }

      # Per-account neomutt identity files
      (lib.listToAttrs (
        map (a: {
          name = "neomutt-${a.name}";
          value = {
            path = "${config.xdg.configHome}/neomutt/${a.name}";
            content = mkNeomuttAccountFile a;
          };
        }) accountList
      ))

      # notmuch config — uses primary account address via sops placeholder
      {
        "notmuch-config" = {
          path = "${config.xdg.configHome}/notmuch/default/config";
          content = ''
            [database]
            path=${config.xdg.dataHome}/mail

            [user]
            name=${ph primaryAccount.realnameSecret}
            primary_email=${ph primaryAccount.addressSecret}

            [new]
            tags=unread;inbox;
            ignore=.mbsyncstate;.uidvalidity;

            [search]
            exclude_tags=deleted;spam;

            [maildir]
            synchronize_flags=true
          '';
        };
      }
    ]; # end sops.templates mkMerge

    # Ensure mbsync activation waits for sops to decrypt secrets
    systemd.user.services.mbsync.Unit.After = [ "sops-nix.service" ];
  };
}
