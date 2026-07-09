# Server — headless, no GUI
# Hosts: Obsidian vault sync (CouchDB) + media stack (Jellyfin/Jellyseerr/
# Sonarr/Radarr/Lidarr/Prowlarr/qBittorrent). Everything on this box is
# reachable only over the tailnet (see common/shared.nix's
# `networking.firewall.trustedInterfaces`), except Jellyfin + Jellyseerr,
# which also get a public URL via Tailscale Funnel for family who don't
# want to install Tailscale — see hosts/server/media.nix.
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../common/shared.nix
    # NOTE: graphical.nix is NOT imported here — no display server on a server
    ./couchdb.nix
    ./media.nix
  ];

  networking.hostName = "nixos-server-0";

 # ── Server packages ───────────────────────────────────────────────────
 # These are system-wide CLI tools for anyone SSHing in.
  environment.systemPackages = with pkgs; [
    tmux   # Terminal multiplexer — keep sessions alive after disconnect
    htop   # Interactive process viewer
    btop   # Nicer process/resource monitor
    rsync  # File sync/backup utility
  ];

  # ── SSH ───────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";         # Never allow direct root SSH
    settings.PasswordAuthentication = false; # SSH keys only (more secure)
    # Explicit regardless of nixpkgs' default: never auto-open SSH on the
    # public/general interface. Reachable over the tailnet only, via
    # networking.firewall.trustedInterfaces in common/shared.nix.
    openFirewall = true;
  };

  # ── Firewall ──────────────────────────────────────────────────────────
  # No general allowedTCPPorts here on purpose. Every service on this
  # server (SSH, CouchDB, Jellyfin, the Starr stack, qBittorrent) is
  # reachable only via the tailnet — see the trustedInterfaces comment in
  # common/shared.nix. Family-facing access to Jellyfin/Jellyseerr goes
  # through Tailscale Funnel instead of opening the firewall.
  networking.firewall.enable = true;

  # ── Shared media/vault storage + permissions group ─────────────────────
  # See README for the full directory layout. Both couchdb.nix and
  # media.nix reference the "media" group defined here.
  users.groups.media = { };

  # ── Users ─────────────────────────────────────────────────────────────
  users.users.graintrain = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "media" ];
    # Set a password with: passwd graintrain
    # Or use: initialHashedPassword = "..."; (generate with mkpasswd)
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII0fASl+vD4hNqi8I4maxxeVDMNZzRvo3mhxe2U1G+4R graintrain@laptop"
    ];
  };

  # ── Home Manager ──────────────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.graintrain = import ../../users/graintrain/server.nix;
  };

# DO NOT TOUCH
  system.stateVersion = "26.05";
# DO NOT TOUCH
}
