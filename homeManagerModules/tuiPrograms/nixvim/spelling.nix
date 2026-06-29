{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myHomeModules.tuiPrograms.nixvim;
  spellingCfg = cfg.spelling;

  defaultLanguageDefinitions = {
    en_us = {
      label = "English";
      key = "e";
      file = "en";
      splHash = "sha256-/sq9yUm2o50ywImfolReqyXmPy7QozxK0VEUJjhNMHA=";
      sugHash = "sha256-W25eYWVYLS/Xob+kH7zoJCxyR2IixV0XwqorqTPJMuw=";
    };
  };

  languageDefinitions = spellingCfg.languageDefinitions // spellingCfg.additionalLanguageDefinitions;
  enabledLanguageNames = lib.unique (spellingCfg.languages ++ lib.attrNames spellingCfg.additionalLanguageDefinitions);
  enabledLanguages = map (language: languageDefinitions.${language}) enabledLanguageNames;

  spellFiles = lib.listToAttrs (
    lib.concatMap (language: [
      {
        name = ".config/nvim/spell/${language.file}.utf-8.spl";
        value.source = pkgs.fetchurl {
          url = "https://ftp.nluug.nl/pub/vim/runtime/spell/${language.file}.utf-8.spl";
          hash = language.splHash;
        };
      }
      {
        name = ".config/nvim/spell/${language.file}.utf-8.sug";
        value.source = pkgs.fetchurl {
          url = "https://ftp.nluug.nl/pub/vim/runtime/spell/${language.file}.utf-8.sug";
          hash = language.sugHash;
        };
      }
    ]) enabledLanguages
  );
in
{
  options.myHomeModules.tuiPrograms.nixvim.spelling = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable declarative Neovim spelling support.";
    };

    languages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "en_us"
      ];
      description = "Spell languages to install and expose through leader mappings.";
    };

    languageDefinitions = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            label = lib.mkOption {
              type = lib.types.str;
              description = "Human-readable language name.";
            };

            key = lib.mkOption {
              type = lib.types.str;
              description = "Suffix used after the spelling mapping prefix.";
            };

            file = lib.mkOption {
              type = lib.types.str;
              description = "Vim spellfile basename, for example `en` for `en.utf-8.spl`.";
            };

            splHash = lib.mkOption {
              type = lib.types.str;
              description = "Hash for the `.spl` spellfile.";
            };

            sugHash = lib.mkOption {
              type = lib.types.str;
              description = "Hash for the `.sug` suggestion file.";
            };
          };
        }
      );
      default = defaultLanguageDefinitions;
      description = "Declarative Vim spellfile definitions keyed by Neovim spelllang name.";
    };

    additionalLanguageDefinitions = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            label = lib.mkOption {
              type = lib.types.str;
              description = "Human-readable language name.";
            };

            key = lib.mkOption {
              type = lib.types.str;
              description = "Suffix used after the spelling mapping prefix.";
            };

            file = lib.mkOption {
              type = lib.types.str;
              description = "Vim spellfile basename, for example `en` for `en.utf-8.spl`.";
            };

            splHash = lib.mkOption {
              type = lib.types.str;
              description = "Hash for the `.spl` spellfile.";
            };

            sugHash = lib.mkOption {
              type = lib.types.str;
              description = "Hash for the `.sug` suggestion file.";
            };
          };
        }
      );
      default = { };
      description = "Host/user-provided spell language definitions that are enabled automatically.";
    };

    mappingPrefix = lib.mkOption {
      type = lib.types.str;
      default = "<leader>s";
      description = "Prefix for spelling mappings.";
    };
  };

  config = lib.mkIf (cfg.enable && spellingCfg.enable) {
    assertions = [
      {
        assertion = lib.all (language: lib.hasAttr language languageDefinitions) enabledLanguageNames;
        message = "Every NixVim spelling language must have a matching language definition.";
      }
    ];

    programs.nixvim = {
      opts.spelllang = lib.concatStringsSep "," enabledLanguageNames;

      keymaps = [
        {
          action = "<cmd>setlocal spell!<CR>";
          key = "${spellingCfg.mappingPrefix}s";
          mode = [
            "n"
            "v"
            "o"
          ];
        }
      ]
      ++ map (language: {
        action = "<cmd>setlocal spell! spelllang=${language}<CR>";
        key = "${spellingCfg.mappingPrefix}${languageDefinitions.${language}.key}";
        mode = [
          "n"
          "v"
          "o"
        ];
      }) enabledLanguageNames;
    };

    home.file = spellFiles;
  };
}
