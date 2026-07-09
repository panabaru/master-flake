# Desktop
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware.nix
    ../../common/shared.nix
    ../../common/graphical.nix # Audio, display, printing, shared graphical tools
  ];

  networking.hostName = "nixos-TurtN";

  # ── Desktop-specific packages ─────────────────────────────────────────
  # Only things the desktop needs that the laptop doesn't.
  environment.systemPackages = with pkgs; [
    swaybg # Wallpaper tool for Sway (replaces swww/hyprpaper which are Hyprland-specific)
  ];

  # ── Login screen ──────────────────────────────────────────────────────
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    wayland.enable = true; # Desktop uses Wayland login
    thyx.enable = true;
  };

  # ── Window manager ────────────────────────────────────────────────────
  # programs.sway must stay in configuration.nix for the same reason as Hyprland:
  # system-level Wayland socket and PAM setup.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Better GTK app integration under Sway
  };

  # ── Unfree packages ───────────────────────────────────────────────────
  # FIX: added "obsidian" — it's in users/shared.nix (used by both users on
  # every host), so this predicate must match the laptop's or the build fails.
  nixpkgs.config.allowUnfreePredicate = pkg: let
    name = pkgs.lib.getName pkg;
  in
    builtins.elem name [ "discord" "spotify" "obsidian" ] ||
    pkgs.lib.hasInfix "steam" name;

  # ── Users ─────────────────────────────────────────────────────────────
  # FIX: DocOrcs is desktop-only (per README + users/DocOrcs/home.nix's own
  # header comment) but was previously defined on the laptop by mistake.
  # Moved here.
  users.users.graintrain = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  
 # ── Home Manager ──────────────────────────────────────────────────────
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.graintrain = import ../../users/graintrain/desktop.nix;
    backupFileExtension = "backup";
  };

# DO NOT CHANGE
  system.stateVersion = "26.05";
# DO NOT CHANGE
}
