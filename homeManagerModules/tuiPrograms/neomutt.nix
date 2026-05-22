{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.myHomeModules.tuiPrograms.neomutt;
in
{
  options.myHomeModules.tuiPrograms.neomutt = {
    enable = lib.mkEnableOption "neomutt TUI mail app";

    mailsyncCommand = lib.mkOption {
      type = lib.types.str;
      default = "mbsync -a";
      description = "Command to sync all mail";
    };

    enableKhard = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable khard integration for contacts";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gnupg
      lynx
      urlscan
      w3m
    ];

    programs.neomutt = {
      enable = true;
      vimKeys = true;
      sidebar = {
        enable = true;
        shortPath = true;
        width = 28;
        format = "%D%* %?F? %F? %?N?%N/?%?S?%S?";
      };
      settings = {
        nobeep = "yes";
        allow_ansi = "yes";
        status_chars = " ";
        date_format = "%Y.%m.%d %H:%M";
        index_format = "%3C %Z %?X?& ? %D %-20.20F %s";
        sidebar_divider_char = " | "; # Character used as divider between sidebar and panels
        sidebar_indent_string = "  "; # Indent mailboxes this amount
        sidebar_next_new_wrap = "yes"; # Should search wrap around when it reaches the end of the list?
        sidebar_sort_method = "unsorted"; # ['unsorted'] Method for sorting the mailboxes
        markers = "no";

        # Migrated from extraConfig
        use_threads = "threads";
        sort = "reverse-last-date";
        sort_aux = "reverse-last-date";
        uncollapse_jump = "yes";
        sort_re = "yes";
        charset = "utf-8";
        send_charset = "utf-8:iso-8859-1:us-ascii";
        pager_index_lines = "15";
        pager_context = "3";
        pager_stop = "yes";
        menu_scroll = "yes";
        tilde = "yes";
        abort_key = "<Esc>";
        mail_check_stats = "yes";
      };
      binds = [
        {
          action = "noop";
          key = "\\Ck";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "noop";
          key = "g";
        }
        {
          action = "noop";
          key = "\\Cj";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "noop";
          key = "\\Co";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "recall-message";
          key = "P";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "group-reply";
          key = "R";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "bottom";
          key = "G";
          map = [ "pager" ];
        }
        {
          action = "top";
          key = "gg";
          map = [ "pager" ];
        }
        {
          action = "last-entry";
          key = "G";
          map = [
            "attach"
            "browser"
            "index"
          ];
        }
        {
          action = "first-entry";
          key = "gg";
          map = [
            "attach"
            "browser"
            "index"
          ];
        }
        {
          action = "complete-query";
          key = "<tab>";
          map = [ "editor" ];
        }

      ];
      macros = [
        {
          action = "<sidebar-prev><sidebar-open>";
          key = "\\Ck";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "<sidebar-next><sidebar-open>";
          key = "\\Cj";
          map = [
            "index"
            "pager"
          ];
        }
        {
          action = "<enter-command>set pipe_decode = yes<enter><pipe-message>urlscan<enter><enter-command>set pipe_decode = no<enter>";
          key = "U";
          map = [
            "index"
            "pager"
          ];
        } # View URLs
      ];

      extraConfig = ''
                #
                # Statusbar, date format, finding stuff etc.
                # set status_chars = " "               # Mailbox status symbols, called with '%r'. 'mailbox is unchanged', 'mailbox has changed and needs to be synced', 'mailbox is read-only', 'attach message mode'
                set to_chars = " "        # 'not adressed to your address', 'you are the only recipient', 'multiple recipient', 'you are cc', 'sent by you', 'mailing list', 'address in reply-to'
                set crypt_chars = " "       # Encryption status symbols, 'signed and verified', 'pgp encrypted', 'signed', 'contains public key', 'no crypto info'
                set flag_chars = " "  # 'tagged', 'important', 'flagged for deletion', 'attachment flagged for deletion', 'replied to', 'old - unread but seen', 'new mail', 'old thread', 'new tread', 'the mail is read'(%S), 'the mail is read' (%Z)
                set status_format = "%*-  %D%r  %m messages%?n? (%n new)?%?d? (%d to delete)?%?t? (%t tagged)?  %?p?(  ---  %p postponed  )?%*-"

                # Allow showing longer attachment file-names (180)
                set attach_format = "%u%D%I %t%4n %T%.180d%> [%.7m/%.10M, %.6e%?C?, %C?, %s] "

                # Additional sidebar settings (see whether programs.neomutt.settings works)
                # set sidebar_divider_char = " | "    # Character used as divider between sidebar and panels
                # set sidebar_indent_string = '  '    # Indent mailboxes this amount
                # set sidebar_sort_method = 'unsorted'    # ['unsorted'] Method for sorting the mailboxes
                
                # color sidebar_divider brightwhite default
                # color sidebar_flagged default default
                # color status brightwhite default

                bind index,pager,browser d noop
                bind index,pager,browser \Cd half-down
                bind index,pager,browser \Cu half-up
                bind pager,index dd delete-message
                bind pager,index u undelete-message
                
                auto_view text/html
                alternative_order text/plain text/enriched text/html
                
                # the programs.neomutt.macros/binds unfortunately doesn't allow for descriptions/helptex. I'll keep most here for now
                macro attach s "<save-entry><bol>$HOME/Downloads/<eol>" "Save to Downloads folder"
                
                # Khard integration for contacts
                ${lib.optionalString cfg.enableKhard ''
                  set query_command = "khard email --parsable '%s'"
                  macro index,pager a "<pipe-message>khard add-email<return>" "add sender to khard contacts"
                ''}

                # Account switching macros — generated from myHomeModules.services.email.accounts.
                # Each account declares a macroKey (e.g. "1" → i1). Per-account identity files
                # are written by sops templates in the email module.
                ${
                  let
                    emailAccounts = lib.attrValues config.myHomeModules.services.email.accounts;
                    primary = lib.findFirst (a: a.primary) null emailAccounts;
                  in
                  lib.concatStringsSep "\n" (
                    map (
                      a:
                      ''macro index,pager i${a.macroKey} '<sync-mailbox><enter-command>source ${config.xdg.configHome}/neomutt/${a.name}<enter><change-folder>!<enter>;<check-stats>' "switch to ${a.name}"''
                    ) emailAccounts
                  )
                  + lib.optionalString (primary != null) ''

                    # Source primary account at startup
                    source ${config.xdg.configHome}/neomutt/${primary.name}
                  ''
                }

                ### From mutt-wizard:
                set mime_type_query_command = "file --mime-type -b %s"
        set smtp_authenticators = 'gssapi:login'
        set rfc2047_parameters = yes
        set sleep_time = 0		# Pause 0 seconds for informational messages
        set mark_old = no		# Unread mail stay unread until read
        set mime_forward = no	# mail body is forwarded as text
        set forward_attachments = yes	# attachments are forwarded with mail
        set wait_key = no		# mutt won't ask "press key to continue"
        set fast_reply			# skip to compose when replying
        set fcc_attach			# save attachments with the body
        set forward_format = "Fwd: %s"	# format of subject when forwarding
        set forward_quote		# include message in forwards
        set reverse_name		# reply as whomever it was to
        set include			# include message in replies
        auto_view application/pgp-encrypted

        bind index,pager i noop
        bind index,pager g noop
        bind index \Cf noop
        bind index,pager M noop
        bind index,pager C noop
        bind editor <space> noop
        bind index h noop

        # General rebindings
        bind index j next-entry
        bind index k previous-entry
        bind attach <return> view-mailcap
        bind attach l view-mailcap
        bind pager,attach h exit
        bind pager j next-line
        bind pager k previous-line
        bind pager l view-attachments
        bind index L limit
        bind index l display-message
        bind index,query <space> tag-entry
        macro browser h '<change-dir><kill-line>..<enter>' "Go to parent folder"
        bind index,pager H view-raw-message
        bind browser l select-entry
        bind index,pager S sync-mailbox
        bind index \031 previous-undeleted	# Mouse wheel
        bind index \005 next-undeleted		# Mouse wheel
        bind pager \031 previous-line		# Mouse wheel
        bind pager \005 next-line		# Mouse wheel

        macro index O "<shell-escape>${cfg.mailsyncCommand}<enter>" "run mailsync to sync all mail"
        macro index \\Cf "<enter-command>unset wait_key<enter><shell-escape>printf 'Enter a search term to find with notmuch: '; read x; echo \$x >\"\''${XDG_CACHE_HOME:-\$HOME/.cache}/mutt_terms\"<enter><limit>~i \"\`notmuch search --output=messages \$(cat \"\''${XDG_CACHE_HOME:-\$HOME/.cache}/mutt_terms\") | head -n 600 | perl -le '@a=<>;s/\^id:// for@a;$,=\"|\";print@a' | perl -le '@a=<>; chomp@a; s/\\+/\\\\+/g for@a; s/\\$/\\\\\\$/g for@a;print@a' \`\"<enter>" "show only messages matching a notmuch pattern"
        macro index A "<limit>all\\n" "show all messages (undo limit)"


        # I've removed all the mutt-wizard color stuff, in the hopes, that stylix can handle it...
      '';
    };

    # Configure mailcap for HTML viewing
    xdg.configFile."neomutt/mailcap".text = ''
      text/html; ${pkgs.lynx}/bin/lynx -dump -width=120 -stdin; nametemplate=%s.html; copiousoutput
      text/html; ${pkgs.w3m}/bin/w3m -dump -cols 120 -T text/html -I %{charset} -O utf-8; copiousoutput
    '';

    xdg.configFile."neomutt/neomuttrc".text = ''
      set nobeep
      set allow_ansi
      set mbox_type = Maildir
      set folder = "${config.xdg.dataHome}/mail"
      set sort = reverse-last-date
      set sort_aux = reverse-last-date
      set sort_re
      set use_threads = threads
      set uncollapse_jump
      set charset = "utf-8"
      set send_charset = "utf-8:iso-8859-1:us-ascii"
      set pager_index_lines = 15
      set pager_context = 3
      set pager_stop
      set menu_scroll
      set tilde
      unset markers
      set abort_key = "<Esc>"
      set mail_check_stats
      set mailcap_path = "${config.xdg.configHome}/neomutt/mailcap"

      set sidebar_visible
      set sidebar_short_path
      set sidebar_width = 28
      set sidebar_format = '%D%* %?F? %F? %?N?%N/?%?S?%S?'
      set sidebar_divider_char = " | "
      set sidebar_indent_string = "  "
      set sidebar_next_new_wrap
      set sidebar_sort_method = unsorted

      bind index,pager i noop
      bind attach,browser,index,pager g noop
      bind index,pager M noop
      bind index,pager C noop
      bind index \Cf noop
      bind editor <space> noop
      bind index h noop
      bind index j next-entry
      bind index k previous-entry
      bind attach <return> view-mailcap
      bind attach l view-mailcap
      bind pager,attach h exit
      bind pager j next-line
      bind pager k previous-line
      bind pager l view-attachments
      bind index L limit
      bind index l display-message
      bind index,query <space> tag-entry
      bind index,pager H view-raw-message
      bind browser l select-entry
      bind index,pager S sync-mailbox
      bind pager G bottom
      bind pager gg top
      bind index gg first-entry
      bind attach,browser,index G last-entry
      bind attach,browser,index gg first-entry
      bind editor <tab> complete-query

      macro index,pager \Cj '<sidebar-next><sidebar-open>'
      macro index,pager \Ck '<sidebar-prev><sidebar-open>'
      macro index,pager U '<enter-command>set pipe_decode = yes<enter><pipe-message>urlscan<enter><enter-command>set pipe_decode = no<enter>' "view URLs"
      macro attach s "<save-entry><bol>$HOME/Downloads/<eol>" "Save to Downloads folder"
      macro browser h '<change-dir><kill-line>..<enter>' "Go to parent folder"
      macro index O "<shell-escape>${cfg.mailsyncCommand}<enter>" "run mailsync to sync all mail"

      ${lib.optionalString cfg.enableKhard ''
        set query_command = "khard email --parsable '%s'"
        macro index,pager a "<pipe-message>khard add-email<return>" "add sender to khard contacts"
      ''}

      ${
        let
          emailAccounts = lib.attrValues config.myHomeModules.services.email.accounts;
          primary = lib.findFirst (a: a.primary) null emailAccounts;
        in
        lib.concatStringsSep "\n" (
          map (
            a:
            ''macro index,pager i${a.macroKey} '<sync-mailbox><enter-command>source ${config.xdg.configHome}/neomutt/${a.name}<enter><change-folder>!<enter>;<check-stats>' "switch to ${a.name}"''
          ) emailAccounts
        )
        + lib.optionalString (primary != null) ''

          source ${config.xdg.configHome}/neomutt/${primary.name}
        ''
      }
    '';
  };
}
