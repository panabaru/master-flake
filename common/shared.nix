# shared.nix — imported by ALL hosts (laptop, desktop, server)
# Only put things here that make sense on every machine, including a headless server.
{ pkgs, ... }: {

  time.timeZone = "America/New_York";

 # Core CLI tools every machine needs
  environment.systemPackages = with pkgs; [
    neovim  		# Text editor
    curl    		# Network transfer tool
    wget    		# File downloader
    git     		# Version control
    unzip
    zip
    smartmontools 	# Check drive stats
  ];
 # Enable flakes + new nix CLI
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
 # Bootloader (works for all three machines as long as they're all EFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
 # Networking
  networking.networkmanager.enable = true;

 # --- Tailscale ---
 # Every host joins the tailnet. After first boot, run `sudo tailscale up`
 # once on each machine to authenticate (see README).
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

 # --- Unfree ---
  nixpkgs.config.allowUnfreePredicate = pkg: let
    name = pkgs.lib.getName pkg;
  in
    builtins.elem name [ "obsidian" ] ||
    pkgs.lib.hasInfix "steam" name;

 # Opens Tailscale's own UDP port (41641 by default) on every interface.
 # This has nothing to do with SSH/Jellyfin/CouchDB reachability (that's
 # entirely handled by trustedInterfaces below) — it's Tailscale's own
 # handshake/data port, used so two devices can find a direct
 # peer-to-peer path to each other instead of relaying all traffic
 # through a slower DERP server. Safe to open: unsolicited packets on it
 # are simply dropped by tailscaled unless they're part of a real
 # WireGuard handshake from a device already on your tailnet.

# tailscale0 is treated as a trusted interface: anything reachable over
 # the tailnet is allowed through the firewall unconditionally, on any
 # port, without needing a per-service allowedTCPPorts entry. This is the
 # entire security boundary for admin UIs (CouchDB, Sonarr/Radarr/etc,
 # qBittorrent's WebUI, SSH) — nothing outside the tailnet can reach them.
 # Jellyfin/Jellyseerr additionally get a public URL via Tailscale Funnel
 # (see hosts/server/media.nix) for family who don't want to install
 # Tailscale.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
