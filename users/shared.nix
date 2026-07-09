# users/shared.nix — Settings shared between ALL users (graintrain + DocOrcs)
# Both graintrain/base.nix and DocOrcs/home.nix import this file.
#
# Good things to put here:
#   - Shell aliases both users want
#   - Common terminal/shell settings
#   - Packages both users need
#
# Do NOT put user-specific things here (usernames, home dirs, etc.)
{ config, pkgs, inputs, ... }:

let
 zen = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {

 # --- Shared packages ---
  home.packages = with pkgs; [
    zen			# Browser
    obsidian		# Note-taking (Obsidian Vault)
    prismlauncher	# Minecraft launcher
    # Add packages both users want here
    # Example: unzip, ripgrep, etc.
  ];

 # --- Shell ---
 # Bash is enabled by default in NixOS but home-manager still needs
 # to manage it to apply things like aliases below.
  programs.bash = {
    enable = true;
    shellAliases = {
      ll  = "ls -la";
      ".." = "cd ..";
      "..."= "cd ../..";
      # Nix shortcuts
      nrs = "sudo nixos-rebuild switch --flake ~/master-flake#$(hostname)";
      nfu = "nix flake update .";
    };
  };

 # --- Git base config ---
 # Each user overrides userName and userEmail in their own file.
 # This just sets shared defaults.
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = false; # Use merge strategy on git pull by default
    };
  };

# DO NOT CHANGE
  home.stateVersion = "26.05";
# DO NOT CHANGE
}
