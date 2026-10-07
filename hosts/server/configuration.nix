# Server — headless, no GUI
# Hosts: Obsidian vault sync (CouchDB) + media stack (Jellyfin/Jellyseerr/
# Sonarr/Radarr/Lidarr/Prowlarr/qBittorrent) + Pi-hole network ad blocking
# (hosts/server/pihole.nix). Everything on this box is
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
    ./storage.nix
    ./caddy.nix
    ./vpn.nix
    ./musicseerr.nix
    ./minecraft.nix
    ./pihole.nix
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: let
    name = pkgs.lib.getName pkg;
  in
    builtins.elem name [ "mdk-sdk" "minecraft-server-26.1.2" ] ||
    pkgs.lib.hasInfix "" name;

  networking.hostName = "nixos-server-0";
 # ── Server packages ───────────────────────────────────────────────────
 # These are system-wide CLI tools for anyone SSHing in.
  environment.systemPackages = with pkgs; [
    tmux   # Terminal multiplexer — keep sessions alive after disconnect
    htop   # Interactive process viewer
    btop   # Nicer process/resource monitor
    rsync  # File sync/backup utility
  ];

  services.minecraft-servers.environmentFile = "/var/lib/secrets/minecraft-env";

  # ── SSH ───────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";         # Never allow direct root SSH
    settings.PasswordAuthentication = false; # SSH keys only (more secure)
   # SSH is already fully reachable over Tailscale without this.
   # Set to false so port 22 is closed everywhere except tailscale0.
    openFirewall = false;
  };

  # ── Firewall ──────────────────────────────────────────────────────────
  # No general allowedTCPPorts here on purpose. Every service on this
  # server (SSH, CouchDB, Jellyfin, the Starr stack, qBittorrent) is
  # reachable only via the tailnet — see the trustedInterfaces comment in
  # common/shared.nix. Family-facing access to Jellyfin/Jellyseerr goes
  # through Tailscale Funnel instead of opening the firewall.
  # Exception: Pi-hole's DNS port (53) is opened by pihole.nix so devices on
  # the home LAN can use it; its dashboard (8053) stays tailnet-only.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 25565 ];
  };
  
  # ── Shared media/vault storage + permissions group ─────────────────────
  # See README for the full directory layout. Both couchdb.nix and
  # media.nix reference the "media" group defined here.
  users.groups.media = { };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;   # formerly hardware.opengl.enable

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    modesetting.enable = true;
    open = false;  # Pascal (GP107 / 10-series) requires the proprietary module,
                   # not NVIDIA's newer open-source kernel module (Turing+ only)
  };

  # ── Users ─────────────────────────────────────────────────────────────
  users.users.graintrain = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "media" ];
    # Set a password with: passwd graintrain
    # Or use: initialHashedPassword = "..."; (generate with mkpasswd)
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKIv/wOTWtwDsyKFwg2MEmbHu1putdPXmo1bCERxyXZ6 graintrain@keemail.me"
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
