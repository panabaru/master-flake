# hosts/server/pihole.nix — network-wide ad blocking (Pi-hole v6 on NixOS)
#
# How it works: Pi-hole is a DNS server. Your devices ask it "what's the IP
# of ads.example.com?" and it answers "doesn't exist" for anything on a
# blocklist, so the ad never loads. Think of it as a receptionist who
# throws away mail from known spammers before it reaches anyone's desk.
#
# Two services make up Pi-hole on NixOS:
#   services.pihole-ftl  — the DNS server + blocklist engine (port 53)
#   services.pihole-web  — the admin dashboard
#
# Ports used:
#   53   (TCP+UDP)  DNS, opened on the firewall below so LAN devices can use it
#   8053 (TCP)      dashboard — NOT 80/443 (Caddy owns those in caddy.nix) and
#                   NOT 8080 (qBittorrent's WebUI, see vpn.nix). Not opened on
#                   the firewall: reachable only over the tailnet, same as
#                   every other admin UI on this box (see common/shared.nix).
#
# Dashboard URL:  http://nixos-server-0.tail782d0d.ts.net:8053/admin
{ config, pkgs, lib, ... }:

{
  services.pihole-ftl = {
    enable = true;

    # Opens 53/tcp + 53/udp. Needed because the LAN is NOT a trusted
    # interface: trustedInterfaces in common/shared.nix lists
    # "192.168.68.0/24", which is a subnet, not an interface name, so NixOS
    # ignores it. (Tailscale clients are already covered by "tailscale0".)
    openFirewallDNS = true;

    # Keep 30 days of query history, then delete it weekly.
    queryLogDeleter = {
      enable = true;
      age = 30;
    };

    # Blocklists. Add more here and rebuild. Hosts-file format lists work
    # best. Lists you remove from this file are NOT removed automatically —
    # delete them in the dashboard (Lists page) if you drop one.
    lists = [
      {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        description = "StevenBlack unified hosts (ads + malware)";
      }
    ];

    settings = {
      dns = {
        # Where Pi-hole forwards the lookups it does NOT block.
        upstreams = [ "1.1.1.1" "9.9.9.9" ];

        # Pi-hole's default only answers devices one network hop away,
        # which would ignore anyone connecting over Tailscale. "ALL" answers
        # every interface; the firewall is what restricts who can reach it
        # (LAN + tailnet only — your router does not forward port 53).
        listeningMode = "ALL";
      };

      webserver.api = {
        # Required so the `lists` above are loaded automatically on startup
        # (the setup script talks to Pi-hole's API with a throwaway password).
        cli_pw = true;
      };
    };
  };

  services.pihole-web = {
    enable = true;
    ports = [ 8053 ];
  };

  # ── Optional: dashboard login password ────────────────────────────────
  # Without this the dashboard has no password, which is okay-ish because
  # only tailnet devices can reach it. To set one WITHOUT putting it in this
  # (public) repo, create the file below on the server:
  #
  #   sudo mkdir -p /var/lib/secrets
  #   echo 'FTLCONF_webserver_api_password=pick-something-good' | sudo tee /var/lib/secrets/pihole-env
  #   sudo chmod 600 /var/lib/secrets/pihole-env
  #
  # The leading "-" means "ignore if the file doesn't exist", so the service
  # still starts before you've created it. Same pattern as minecraft-env.
  systemd.services.pihole-ftl.serviceConfig.EnvironmentFile = "-/var/lib/secrets/pihole-env";

  # ── Weekly blocklist refresh ──────────────────────────────────────────
  # pihole-ftl-setup downloads every list in `lists` and rebuilds the block
  # database (it runs `pihole -g` at the end). It only runs at boot / rebuild
  # by default, so re-run it every Sunday to pick up new ad domains.
  systemd.services.pihole-gravity-update = {
    description = "Refresh Pi-hole blocklists";
    serviceConfig.Type = "oneshot";
    script = "${config.systemd.package}/bin/systemctl restart pihole-ftl-setup.service";
    startAt = "Sun 04:00";
  };
}
