{ ... }:
{
  vpnNamespaces.mullvad = {
    enable = true;
    wireguardConfigFile = "/etc/wireguard-secrets/us-nyc-wg-501.conf";
    accesibleFrom = [ "100.64.0.0/10" ];  
    portMappings = [
      { from = 8080; to = 8080; }
    ];
  };

  systemd.services.qbittorrent.vpnConfinement = {
    enable = true;
    vpnNamespace = "mullvad";
  };
