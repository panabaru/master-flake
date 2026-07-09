# graintrain/desktop.nix — Desktop-only home config for graintrain
{ pkgs, ... }: {

  imports = [ ./base.nix ];

  # ── Desktop-only packages ─────────────────────────────────────────────
  home.packages = with pkgs; [
    obs-studio # Screen recording / streaming
    gimp       # Image editor
  ];

  # Sway config goes here once you have dotfiles for it.
  # e.g.: home.file.".config/sway/config".source = ./sway.conf;
}
