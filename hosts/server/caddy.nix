{ ... }:
{
  services.caddy = {
    enable = true;
    virtualHosts."nixos-server-0.tail782d0d.ts.net".extraConfig = ''
      reverse_proxy 127.0.0.1:5984
    '';
  };

  # Lets Caddy (running as its own unprivileged user) fetch/renew
  # certificates from the Tailscale daemon without needing root.
  services.tailscale.permitCertUid = "caddy";
}
