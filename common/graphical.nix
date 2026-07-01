# graphical.nix — imported by DESKTOP and LAPTOP only (not server)
{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
   # Terminal 
    kitty     				# Terminal emulator
    fastfetch 				# System info in terminal
   # Shell 
    waybar    				# Status bar
    rofi				# App launcher (Wayland-native version)
    mako      				# Notifications
    pavucontrol				# Audio control GUI (clickable from waybar)
    networkmanagerapplet		# Newtork tray icon
   # File Managing 
    yazi      				# Terminal file manager
    thunar    				# Graphical file manager
   # Permission 
    pantheon.pantheon-agent-polkit      # Graphical sudo prompt
   # Screenshots
    grim				# Wayland screenshot
    slurp				# Screenshot region select
   # Miscellaneous
    wl-clipboard			# Copy/paste for wayland
  ];

 # Nerd Fonts — required for waybar icons
 # JetBrainsMono Nerd Font is a clean monospace font with icon support
  fonts.packages = with pkgs; [ 
    nerd-fonts.jetbrains-mono  # Practical
    nerd-fonts.departure-mono  # Pixely
    nerd-fonts.heavy-data      # Buffy sci-fy
  ];
 # Audio
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
 # Printing
  services.printing.enable = true;
 # Trackpad etc.
  services.libinput.enable = true;
 # Graphics
  services.xserver = {
    enable = true;
    #windowmanager.xterm.enable = false;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

 # Steam (gaming library) — desktop/laptop only, moved out of common/shared.nix
 # so the server doesn't get Steam packages or its firewall rules.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  hardware.steam-hardware.enable = true;
  environment.sessionVariables = {
    STEAM_FRAME_FORCE_CLOSE = "0";
    GAMEMODE_PREFIX = "gamemoderun";
  };
}
