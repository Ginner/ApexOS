{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.myHomeModules.cliPrograms.latex;

  schemePackage =
    if cfg.scheme == "small" then
      pkgs.texlive.scheme-small
    else if cfg.scheme == "medium" then
      pkgs.texlive.scheme-medium
    else
      pkgs.texlive.scheme-full;

  texlivePackage = pkgs.texlive.combine (
    {
      scheme = schemePackage;

      inherit (pkgs.texlive)
        latex-bin
        latexmk
        xetex
        collection-latexrecommended
        collection-fontsrecommended
        ;
    }
    // cfg.extraPackages pkgs.texlive
  );
in
{
  options.myHomeModules.cliPrograms.latex = {
    enable = lib.mkEnableOption "LaTeX distribution and tools";

    enableFull = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable full texlive distribution (large download)";
    };

    scheme = lib.mkOption {
      type = lib.types.enum [
        "small"
        "medium"
        "full"
      ];
      default = if cfg.enableFull then "full" else "medium";
      description = "LaTeX scheme to install";
    };

    extraPackages = lib.mkOption {
      type = lib.types.functionTo (lib.types.attrsOf lib.types.package);
      default = _: { };
      description = "Additional TeX Live packages to include in the combined distribution.";
      example = lib.literalExpression ''
        texlive: {
          inherit (texlive) wallpaper;
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      texlivePackage
    ];
  };
}
