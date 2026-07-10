# hosts/server/media.nix — Movies/TV/Music pipeline:
#   Jellyseerr (family requests)
#     -> Sonarr (TV) / Radarr (movies) / Lidarr (music)
#     -> Prowlarr (indexer manager, feeds all three above)
#     -> qBittorrent (does the actual downloading)
#     -> Jellyfin (streams the finished result)
#
# All of these run as native NixOS services (not the Nixflix/nixarr flakes)
# so behaviour is stable and doesn't depend on a third-party module's API
# staying compatible across your future `nix flake update`s. First-time
# setup for each app (creating a Jellyfin library, adding indexers to
# Prowlarr, connecting Sonarr/Radarr/Lidarr to Prowlarr + qBittorrent) is
# done once through each app's own web UI after first boot — see README.
{ config, pkgs, ... }:

{
  # ── Shared storage layout ────────────────────────────────────────────
  # /data/media    — the finished library Jellyfin reads
  # /data/torrents — qBittorrent's working directory
  # Kept as SIBLINGS under the same top-level /data so Sonarr/Radarr/Lidarr
  # can hardlink+atomic-move a finished download into the library instead
  # of doing a slow cross-filesystem copy+delete (this only works if both
  # directories live on the same filesystem/mount).
  #
  # If you're putting media on a separate drive, mount it at /data in
  # hosts/server/hardware.nix (fileSystems."/data" = { ... };) BEFORE
  # deploying this — these directories will otherwise just live on your
  # root filesystem.
  systemd.tmpfiles.rules = [
    "d /data 2775 root media -"
    "d /data/media 2775 root media -"
    "d /data/media/movies 2775 root media -"
    "d /data/media/tv 2775 root media -"
    "d /data/media/music 2775 root media -"
    "d /data/media/anime 2775 root media -"
    "d /data/torrents 2775 root media -"
    "d /data/torrents/movies 2775 root media -"
    "d /data/torrents/tv 2775 root media -"
    "d /data/torrents/music 2775 root media -"
    "d /data/torrents/anime 2775 root media -"
  ];

  # ── Jellyfin ──────────────────────────────────────────────────────────
  services.jellyfin = {
    enable = true;
    # FIX: openFirewall = true previously opened 8096/8920 on the PUBLIC
    # interface. Removed — reachability is tailnet-only via
    # trustedInterfaces, plus a public URL via Funnel below.
    group = "media"; # so it can read /data/media
  };

  # ── Jellyseerr — the "request a show" UI for family ─────────────────────
  services.jellyseerr = {
    enable = true;
    # port defaults to 5055
  };

  # ── Prowlarr — indexer manager, feeds Sonarr/Radarr/Lidarr ──────────────
  services.prowlarr.enable = true; # port 9696

  # ── Sonarr (TV) ───────────────────────────────────────────────────────
  services.sonarr = {
    enable = true; # port 8989
    group = "media";
  };

  # ── Radarr (movies) ───────────────────────────────────────────────────
  services.radarr = {
    enable = true; # port 7878
    group = "media";
  };

  # ── Lidarr (music) ────────────────────────────────────────────────────
  services.lidarr = {
    enable = true; # port 8686
    group = "media";
  };

  # ── qBittorrent ───────────────────────────────────────────────────────
  services.qbittorrent = {
    enable = true;
    webuiPort = 8080;
    torrentingPort = 6881;
    group = "media";
    # openFirewall intentionally left off (default). The WebUI (8080) is
    # tailnet-only like everything else here. The torrentingPort (6881) is
    # a DIFFERENT concern — that one wants to be reachable by other
    # bittorrent peers on the internet for good download speed, which is
    # exactly what your existing torrent VPN provider's port-forwarding
    # feature is for. Since you already run qBittorrent through a separate
    # VPN, route/port-forward 6881 through THAT VPN's tooling rather than
    # this firewall — happy to wire that in once you tell me which
    # provider/config you're using (e.g. an OpenVPN or WireGuard config
    # file qBittorrent's network namespace should bind to).
  };

  # ── Tailscale Funnel — public URL for Jellyfin + Jellyseerr only ────────
  # Funnel isn't a NixOS option — it's a runtime `tailscale` CLI command
  # whose config persists in tailscaled's own state and auto-resumes after
  # reboots. Run these ONCE after first boot (see README):
  #
  #   sudo tailscale funnel --bg 8096   # Jellyfin
  #   sudo tailscale funnel --bg 5055   # Jellyseerr
  #
  # Everything else on this box (Sonarr, Radarr, Lidarr, Prowlarr,
  # qBittorrent's WebUI, CouchDB, SSH) deliberately has NO Funnel — those
  # stay tailnet-only.
}
