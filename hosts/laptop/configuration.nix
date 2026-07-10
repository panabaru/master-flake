# Laptop — ThinkPad T590
{ config, lib, pkgs, inputs, ... }:

let 
  my-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
    themeConfig = {
      font = "DepartureMono Nerd Font";
    };
  };
in
{
  imports = [
    ./hardware.nix
    ../../common/shared.nix
    ../../common/graphical.nix
  ];
  networking.hostName = "nixos-t590";
 # --- Laptop-specific system packages ---
  environment.systemPackages = with pkgs; [
    awww          		# Animated wallpaper daemon (Hyprland-specific)
    brightnessctl 		# Screen brightness control (used by keybinds below)
    kdePackages.qtmultimedia
    my-astronaut
    kdePackages.qtsvg
  ];
 # --- Login screen --- 
 services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    #wayland.enable = false;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      my-astronaut
      kdePackages.qtmultimedia
      kdePackages.qtsvg
    ];
  };
 # --- Window manager ---
 # Must be in configuration.nix — Hyprland needs kernel Wayland sockets + PAM
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
 # --- Unfree packages ---
  nixpkgs.config.allowUnfreePredicate = pkg: let
    name = pkgs.lib.getName pkg;
  in
    builtins.elem name [ "discord" "spotify" "obsidian" ] ||
    pkgs.lib.hasInfix "steam" name;

# --- Users ---
 # FIX: DocOrcs is desktop-only (see hosts/desktop/configuration.nix) —
 # was previously defined here by mistake.
  users.users.graintrain = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  users.users.DocOrcs = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
  };
 # --- Home Manager ---
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.graintrain = import ../../users/graintrain/laptop.nix;
    users.DocOrcs = import ../../users/DocOrcs/home.nix;
    backupFileExtension = "backup";
  };

# DO NOT CHANGE
  system.stateVersion = "26.05";
# DO NOT CHANGE
}
