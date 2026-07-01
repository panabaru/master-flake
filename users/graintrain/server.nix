# graintrain/server.nix — Server-only home config for graintrain
# Focused on terminal tools for managing the server. No graphical apps.
{ pkgs, ... }: {

  imports = [ ./base.nix ];

  # ── Server management packages ────────────────────────────────────────
  # NOTE: These go in home.packages (not environment.systemPackages) because
  # they're tools for YOU specifically, not tools every user needs system-wide.
  home.packages = with pkgs; [
    btop       # Visual resource monitor (CPU, RAM, disk, network)
    ncdu       # Visual disk usage explorer
    lazydocker # Terminal UI for Docker (if you end up using Docker)
    jq         # JSON processor — useful for scripting server tasks
  ];

  # ── Tmux — terminal multiplexer ──────────────────────────────────────
  # Essential on a server: keeps your sessions alive even after you disconnect.
  # Attach back to a running session with: tmux attach
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    keyMode = "vi";
    extraConfig = ''
      # Use Ctrl+Space as prefix instead of Ctrl+B (easier to type)
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # Split panes with | and -
      bind | split-window -h
      bind - split-window -v

      # Status bar
      set -g status-right '#H  %Y-%m-%d %H:%M'
    '';
  };

  # ── Shell — server-specific aliases ──────────────────────────────────
  programs.bash = {
    enable = true;
    shellAliases = {
      # Logs
      jf-log   = "sudo journalctl -u jellyfin -f";     # Jellyfin
      cdb-log  = "sudo journalctl -u couchdb -f";       # CouchDB (Obsidian sync)
      qbt-log  = "sudo journalctl -u qbittorrent -f";   # qBittorrent
      arr-log  = "sudo journalctl -u sonarr -u radarr -u lidarr -u prowlarr -f";
      # Restarts
      jf-restart  = "sudo systemctl restart jellyfin";
      cdb-restart = "sudo systemctl restart couchdb";
      # Quick status across the whole media stack
      media-status = "systemctl status jellyfin jellyseerr sonarr radarr lidarr prowlarr qbittorrent couchdb --no-pager";
    };
  };

# DO NOT CHANGE
  home.stateVersion = "26.05";
# DO NOT CHANGE
}
