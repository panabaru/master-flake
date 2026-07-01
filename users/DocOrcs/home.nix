# DocOrcs/home.nix — Home config for DocOrcs (desktop only)
{ pkgs, inputs, ... }:

let
  zen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {

  imports = [ ../shared.nix ]; # Common settings shared with graintrain

  home.username    = "DocOrcs";
  home.homeDirectory = "/home/DocOrcs";

 # --- DocOrcs packages ---
  home.packages = with pkgs; [
    firefox  # Firefox (backup browser)
    discord  # Discord
    spotify  # Spotify
  ];

 # --- Git (DocOrcs-specific) --- 
  programs.git = {
    userName  = "DocOrcs";
    userEmail = ""; # Add DocOrcs's email here if needed
  };

# DO NOT TOUCH
  home.stateVersion = "26.05";
# DO NOT TOUCH
}
