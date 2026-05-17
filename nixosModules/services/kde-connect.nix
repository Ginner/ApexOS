{ lib, config, ... }:

let
  cfg = config.myModules.services.kde-connect;
in
{
  options.myModules.services.kde-connect = {
    enable = lib.mkEnableOption "KDE Connect firewall and mDNS support";
  };

  config = lib.mkIf cfg.enable {
    # KDE Connect requires ports 1714–1764 (TCP+UDP). These are not optional —
    # the service will not function without them.
    networking.firewall = {
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    };

    # Avahi provides mDNS device discovery on the local network.
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
