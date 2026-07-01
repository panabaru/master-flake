# graintrain/base.nix — Settings graintrain has on ALL machines
# laptop.nix, desktop.nix, and server.nix all import this.
{ config, pkgs, inputs, ... }: 
{

  imports = [ ../shared.nix ]; # Common setting shared with DocOrcs

  home.username    = "graintrain";
  home.homeDirectory = "/home/graintrain";
 # --- Packages on all graintrain machines ---
  home.packages = with pkgs; [
    
  ];
 # --- Git (graintrain-specific config overrides shared.nix defaults) ---
  programs.git = {
    enable = true;
    settings.user = {
      user.name  = "panabaru";
      user.email = "graintrain@keemail.me"; # Add your email here
    };
  };
}
