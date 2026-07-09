# master-flake

A NixOS flake, using `home-manager`, for three machines sharing one repo:

- **laptop** (flake attribute `nixos-t590`, hostname `nixos-t590`) — ThinkPad T590, graphical, Hyprland
- **desktop** (flake attribute `desktop`, hostname `nixos-TurtN`) — graphical, Sway
- **server** (flake attribute `server`, hostname `nixos-server-0`) — headless: Jellyfin/Jellyseerr/Sonarr/Radarr/Lidarr/Prowlarr/qBittorrent media stack + CouchDB for Obsidian sync

All three machines join a private [Tailscale](https://tailscale.com) network (tailnet). Every
admin-facing service on the server (SSH, CouchDB, Jellyfin, the \*arr apps, qBittorrent's
WebUI) is reachable **only** from devices on that tailnet — nothing is exposed to the public
internet, except Jellyfin/Jellyseerr, which can optionally also get a public URL via Tailscale
Funnel for family who don't want to install Tailscale (see `hosts/server/media.nix`).

## Repo layout

```
common/shared.nix      — settings every host needs (Tailscale, SSH client, firewall, timezone)
common/graphical.nix   — settings only laptop/desktop need (audio, display, Steam, fonts)
hosts/<name>/configuration.nix — per-machine system config
hosts/<name>/hardware.nix      — per-machine generated hardware config (disks, kernel modules)
hosts/server/couchdb.nix       — Obsidian vault sync (CouchDB)
hosts/server/media.nix         — Jellyfin + the *arr stack + qBittorrent
users/graintrain/*.nix         — graintrain's home-manager config, one file per host
users/DocOrcs/home.nix         — DocOrcs's home-manager config (desktop only)
users/shared.nix               — home-manager settings shared by every user on every host
```

Server media/vault storage layout (created automatically by `hosts/server/media.nix`):

```
/data/media/{movies,tv,music}     — finished library, read by Jellyfin
/data/torrents/{movies,tv,music}  — qBittorrent's working directory
```

If your media lives on a separate drive, mount it at `/data` in `hosts/server/hardware.nix`
*before* first deploying `media.nix`, so both directories above land on that drive.

## First-boot checklist (new server, or after moving to a new machine)

1. Clone this repo to `~/master-flake` on every machine (the `nrs` shell alias in
   `users/shared.nix` assumes this path).
2. Replace the placeholder `hosts/<name>/hardware.nix` with the real one:
   `nixos-generate-config --show-hardware-config > hardware.nix`.
3. `sudo nixos-rebuild switch --flake .#<attribute>` (`nixos-t590`, `desktop`, or `server`).
4. On every machine: `sudo tailscale up`, then approve the device in
   [the Tailscale admin console](https://login.tailscale.com/admin/machines) if needed.
5. On the server, set the graintrain Linux password: `sudo passwd graintrain`.
6. On the server, set the real CouchDB admin account (see `hosts/server/couchdb.nix` for why
   this is a manual, one-time step rather than something declared in this repo):
   ```
   curl -X PUT http://127.0.0.1:5984/_node/_local/_config/admins/graintrain \
        -d '"choose-a-real-password-here"'
   ```
7. Create a CouchDB database per Obsidian vault and point each device's "Self-hosted LiveSync"
   plugin at it — see `hosts/server/couchdb.nix`.
8. First-time setup for each media app (Jellyfin library, Prowlarr indexers, connecting
   Sonarr/Radarr/Lidarr to Prowlarr + qBittorrent) is done once through each app's own web UI.

## Rebuilding after a config change

```
nrs          # alias for: sudo nixos-rebuild switch --flake ~/Downloads/dotfilesAI#$(hostname)
```
