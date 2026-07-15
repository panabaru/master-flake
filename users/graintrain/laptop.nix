# graintrain/laptop.nix — Laptop home config (Hyprland rice, school workflow)
# Color scheme: Catppuccin Mocha
{ pkgs, config, inputs, ... }:

{
  imports = [ ./base.nix ];

 # --- Laptop-specific packages ---
  home.packages = with pkgs; [
    fladder
  ];

 # --- Screenshot directory ---
 # Creates ~/Pictures/Screenshots so the screenshot keybind has somewhere to save
  home.file."Pictures/Screenshots/.keep".text = "";

 # --- Wallpaper placeholder ---
 # Put any image you like at ~/Pictures/wallpaper.jpg and Hyprland will use it.
 # You can change the path in exec-once below.

 # ══════════════════════════════════════════════════════════════════════
 # HYPRLAND — Window manager config
 # All keybinds use Super (Windows key) as the modifier.
 # ══════════════════════════════════════════════════════════════════════
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true; # Integrate with systemd for proper session management
    configType = "hyprlang";
    package = null;

    settings = {
      "$mod" = "SUPER";

     # Auto-detect monitor, use preferred resolution and refresh rate
      monitor = ",preferred,auto,1";

     # --- Startup programs ---
      exec-once = [
        "awww-daemon"                                         # Start wallpaper daemon
        "awww img ~/Pictures/wallpaper.jpg"          	      # Set wallpaper
        "waybar"                                              # Start status bar
        "mako"                                                # Start notifications
        "nm-applet --indicator"                               # Network tray icon
      ];

     # --- General appearance ---
     # Catppuccin Mocha: mauve + blue gradient border, gray inactive
      general = {
        gaps_in = 4;
        gaps_out = 6;
        border_size = 2;
        "col.active_border"   = "rgba(cba6f7ff) rgba(89b4faff) 45deg";
        "col.inactive_border" = "rgba(585b70aa)";
        layout = "dwindle";
        allow_tearing = false;
      };

     # --- Decorations (rounding, blur, shadow) ---
      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 4;
          passes = 2;
          vibrancy = 0.17;
        };
	shadow = {
          enabled = true;
	  range = 8;
	  render_power = 2;
	  color = "rgba(1a1a2ecc)";
	};
        #drop_shadow = true;
        #shadow_range = 8;
        #shadow_render_power = 2;
        #"col.shadow" = "rgba(1a1a2ecc)";
      };

     # --- Animations ---
      animations = {
        enabled = true;
       # Smooth spring curve for windows, simple fade elsewhere
        bezier = [
          "spring, 0.05, 0.9, 0.1, 1.05"
          "linear, 0, 0, 1, 1"
        ];
        animation = [
          "windows,    1, 6,  spring"
          "windowsOut, 1, 5,  default, popin 80%"
          "border,     1, 10, linear"
          "fade,       1, 4,  linear"
          "workspaces, 1, 5,  spring, slidevert"
        ];
      };

     # --- Layout ---
      dwindle = {
        preserve_split = true;  # Keep split direction when closing windows
      };

	
     # --- Input ---
      input = {
        kb_layout = "us";
        follow_mouse = 1;     # Focus follows mouse
        sensitivity = 0;      # 0 = no pointer acceleration
        touchpad = {
          natural_scroll = false;    # Scroll direction matches trackpad movement - true
          tap-to-click = true;
          disable_while_typing = true;
        };
      };

     # Trackpad gestures
      "gesture" = "3, horizontal, workspace";

      misc = {
        force_default_wallpaper = 0; # Don't show Hyprland's default anime wallpaper
        disable_hyprland_logo = true;
      };

     # ── Keybinds ──────────────────────────────────────────────────
     # Super+T = terminal | Super+B = browser | Super+O = Obsidian
     # Super+R = app launcher | Super+E = file manager | Super+G = Prism Launcher
     # Super+Q = close window | Super+F = fullscreen
     # Super+V = toggle floating | Super+[1-9] = switch workspace
     # Super+Shift+[1-9] = move window to workspace
     # Print = screenshot region | Shift+Print = screenshot fullscreen
      bind = [
       # App launchers
        "$mod, T, exec, kitty"       # Default - "super, Q"
        "$mod, B, exec, zen-beta"
        "$mod, O, exec, obsidian"
        "$mod, E, exec, thunar"
        "$mod, R, exec, rofi -show drun"
	"$mod, S, exec, steam"
	"$mod, P, exec, prismlauncher"  # Moved from $mod+P — that key was also bound to `pseudo` below and Hyprland silently drops the first match
       # Window management
        "$mod, Q, killactive"        # Default - "super, C"
        "$mod, M, exit"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
	"$mod, J, layoutmsg"       # Swap dwindle split direction : default - "super, J" 
       # Focus (arrow keys)
        "$mod, left,  movefocus, l"  # Default - "super, left"
        "$mod, right, movefocus, r"  # Default - "super, right"
        "$mod, up,    movefocus, u"  # Default - "super, up"
        "$mod, down,  movefocus, d"  # Default - "super, down"
       # Workspaces 1–9              # Default - "super, #" / "super, SHIFT, #"
        "$mod, 1, workspace, 1"  "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod, 2, workspace, 2"  "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod, 3, workspace, 3"  "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod, 4, workspace, 4"  "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod, 5, workspace, 5"  "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod, 6, workspace, 6"  "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod, 7, workspace, 7"  "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod, 8, workspace, 8"  "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod, 9, workspace, 9"  "$mod SHIFT, 9, movetoworkspace, 9"
       # Screenshots (saved to ~/Pictures/Screenshots/)
        ", Print,       exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png"
        "SHIFT, Print,  exec, grim ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png"
      ];

     # Repeating keybinds (held down = repeat) — volume and brightness
      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
        ", XF86MonBrightnessUp,  exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown,exec, brightnessctl set 5%-"
      ];

     # Single-press keybinds (no repeat)
      bindl = [
        ", XF86AudioMute,       exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay,       exec, playerctl play-pause"
        ", XF86AudioNext,       exec, playerctl next"
        ", XF86AudioPrev,       exec, playerctl previous"
      ];

     # Mouse binds — Super+click to move/resize floating windows
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

     # ── Window rules ──────────────────────────────────────────────
     # Make certain windows open as floating dialogs
      windowrule = [
        "match:class ^(pavucontrol)$, float 1"
        "match:class ^(nm-connection-editor)$, float 1"
        "match:class ^(thunar)$, float 1"
       # Obsidian opens maximized
        "match:class ^(obsidian)$, maximize 1"
      ];
    };
  };

 # ══════════════════════════════════════════════════════════════════════
 # WAYBAR — Status bar (Catppuccin Mocha theme)
 # Layout: [Workspaces | Window title]  [Clock]  [Vol | Net | Battery | Tray]
 # ══════════════════════════════════════════════════════════════════════
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 40;
        spacing = 4;

        modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right  = [ "pulseaudio" "network" "battery" "tray" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          format-icons = {
            "1" = "󰲡"; "2" = "󰲣"; "3" = "󰲥";
            "4" = "󰲧"; "5" = "󰲩";
            active  = "󰮯";
            default = "󰊠";
          };
          persistent-workspaces = {
            "*" = 5; # Always show 5 workspaces
          };
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 60;
          separate-outputs = true;
        };

        clock = {
          timezone = "America/New_York";
          format     = "󰥔  {:%H:%M}";
          format-alt = "󰃭  {:%A, %d %B %Y}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        battery = {
          states = { good = 80; charge = 30; critical = 15; };
          format          = "{icon}  {capacity}%";
          format-charging = "󰂄  {capacity}%";
          format-plugged  = "󰚥  {capacity}%";
          format-icons    = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          tooltip-format  = "{timeTo}";
        };

        network = {
          format-wifi       = "󰤨  {essid}";
          format-ethernet   = "󰈀  Wired";
          format-disconnected = "󰤭  No network";
          tooltip-format    = "{ipAddr}  ▲ {bandwidthUpBytes}  ▼ {bandwidthDownBytes}";
          on-click          = "nm-connection-editor";
        };

        pulseaudio = {
          format       = "{icon}  {volume}%";
          format-muted = "󰝟  Muted";
          format-icons = { default = [ "󰕿" "󰖀" "󰕾" ]; };
          on-click     = "pavucontrol";
          scroll-step  = 5;
        };

        tray = { spacing = 15; };
      };
    };

   # ── Waybar CSS (Catppuccin Mocha) ──────────────────────────────
    style = ''
      /* ── Catppuccin Mocha palette ──────────────────────────────── */
      @define-color base    #1e1e2e;
      @define-color mantle  #181825;
      @define-color surface0 #313244;
      @define-color text    #cdd6f4;
      @define-color subtext1 #bac2de;
      @define-color overlay0 #6c7086;
      @define-color blue    #89b4fa;
      @define-color lavender #b4befe;
      @define-color mauve   #cba6f7;
      @define-color pink    #f38ba8;
      @define-color red     #f38ba8;
      @define-color yellow  #f9e2af;
      @define-color green   #a6e3a1;
      @define-color teal    #94e2d5;

      /* ── Reset ─────────────────────────────────────────────────── */
      * {
        font-family: "DepartureMono Nerd Font", monospace;
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
        padding: 0;
        margin: 0;
      }

      /* ── Bar background — slightly transparent dark base ────────── */
      window#waybar {
        background-color: transparent;
        color: @text;
      }

      /* ── Module group pills ─────────────────────────────────────── */
      .modules-left,
      .modules-center,
      .modules-right {
        background-color: alpha(@base, 0.92);
        border-radius: 12px;
        margin: 5px 6px;
        padding: 0 6px;
      }

      /* ── Workspaces ─────────────────────────────────────────────── */
      #workspaces {
        padding: 0 4px;
      }

      #workspaces button {
        padding: 2px 8px;
        color: @overlay0;
        background: transparent;
        border-radius: 8px;
        transition: all 0.2s ease;
      }

      #workspaces button.active {
        color: @mauve;
        background: alpha(@mauve, 0.15);
      }

      #workspaces button.occupied {
        color: @subtext1;
      }

      #workspaces button:hover {
        color: @lavender;
        background: alpha(@lavender, 0.12);
      }

      /* ── Window title ───────────────────────────────────────────── */
      #window {
        color: @subtext1;
        padding: 0 8px;
        font-style: italic;
      }

      /* ── Clock ──────────────────────────────────────────────────── */
      #clock {
        color: @blue;
        font-weight: bold;
        padding: 0 12px;
      }

      /* ── Battery ────────────────────────────────────────────────── */
      #battery {
        color: @green;
        padding: 0 10px;
      }

      #battery.warning { color: @yellow; }
      #battery.critical {
        color: @red;
        animation: blink 1s infinite;
      }

      @keyframes blink {
        to { color: alpha(@red, 0.4); }
      }

      /* ── Network ────────────────────────────────────────────────── */
      #network {
        color: @teal;
        padding: 0 10px;
      }

      #network.disconnected { color: @overlay0; }

      /* ── Audio ──────────────────────────────────────────────────── */
      #pulseaudio {
        color: @mauve;
        padding: 0 10px;
      }

      #pulseaudio.muted { color: @overlay0; }

      /* ── Tray ───────────────────────────────────────────────────── */
      #tray {
        padding: 0 8px;
      }

      #tray > .passive { -gtk-icon-effect: dim; }
      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background-color: alpha(@red, 0.2);
        border-radius: 8px;
      }
    '';
  };

 # ══════════════════════════════════════════════════════════════════════
 # MAKO — Notification daemon (Catppuccin Mocha)
 # ══════════════════════════════════════════════════════════════════════
  services.mako = {
    enable = true;
    settings = {
      background-color = "#1e1e2ef0"; # base with slight transparency
      text-color       = "#cdd6f4";   # text
      border-color     = "#cba6f7";   # mauve
      border-radius    = 10;
      border-size      = 2;
      padding          = "12,16";
      margin           = "10";
      width            = 350;
      max-history      = 20;
      font             = "DepartureMono Nerd Font 11";
      default-timeout  = 5000;  # 5 seconds
      ignore-timeout   = 0;
      layer            = "overlay";

     # Urgent notifications (e.g. low battery) stay visible longer
      "[urgency=high]" = {
        border-color    = "#f38ba8"; # red
        default-timeout = 0;         # stays until dismissed
      };
    };
  };

 # ══════════════════════════════════════════════════════════════════════
 # ROFI — App launcher (Catppuccin Mocha)
 # Open with Super+R, search by typing, Enter to launch
 # ══════════════════════════════════════════════════════════════════════
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;  
    font = "DepartureMono Nerd Font 13";
    terminal = "kitty";
    extraConfig = {
      modi = "drun,run";
      show-icons = true;
      display-drun = "󰀻  Apps";
      display-run  = "󰆍  Run";
      drun-display-format = "{name}";
      icon-theme = "Papirus-Dark";
    };
   # Catppuccin Mocha theme
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        bg0 = mkLiteral "#1e1e2ef0";
        bg1 = mkLiteral "#313244";
        fg0 = mkLiteral "#cdd6f4";
        fg1 = mkLiteral "#bac2de";
        ac  = mkLiteral "#cba6f7";
        rd  = mkLiteral "#f38ba8";
        background-color = mkLiteral "transparent";
        text-color       = mkLiteral "@fg0";
      };
      "window" = {
        background-color = mkLiteral "@bg0";
        border       = mkLiteral "2px";
	border-color = mkLiteral "@ac";
        border-radius = mkLiteral "12px";
        padding      = mkLiteral "20px";
        width        = mkLiteral "500px";
      };
      "mainbox" = { background-color = mkLiteral "transparent"; };
      "inputbar" = {
        background-color = mkLiteral "@bg1";
        border-radius    = mkLiteral "8px";
        padding          = mkLiteral "8px 12px";
        margin           = mkLiteral "0 0 12px 0";
        children         = map mkLiteral [ "prompt" "entry" ];
      };
      "prompt" = {
        background-color = mkLiteral "transparent";
        text-color       = mkLiteral "@ac";
        margin           = mkLiteral "0 8px 0 0";
      };
      "entry" = { background-color = mkLiteral "transparent"; };
      "listview" = {
        background-color = mkLiteral "transparent";
        lines            = mkLiteral "8";
        spacing          = mkLiteral "4px";
      };
      "element" = {
        background-color = mkLiteral "transparent";
        padding          = mkLiteral "8px 12px";
        border-radius    = mkLiteral "8px";
        spacing          = mkLiteral "8px";
      };
      "element selected" = {
        background-color = mkLiteral "#cba6f733";
        text-color       = mkLiteral "@ac";
      };
      "element-text" = {
        background-color = mkLiteral "transparent";
        text-color       = mkLiteral "inherit";
      };
      "element-icon" = {
        background-color = mkLiteral "transparent";
        size             = mkLiteral "24px";
      };
    };
  };

 # ══════════════════════════════════════════════════════════════════════
 # KITTY — Terminal (Catppuccin Mocha)
 # ══════════════════════════════════════════════════════════════════════
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    settings = {
     # Catppuccin Mocha colors
      foreground            = "#cdd6f4";
      background            = "#1e1e2e";
      selection_foreground  = "#1e1e2e";
      selection_background  = "#f5e0dc";
      cursor                = "#f5e0dc";
      cursor_text_color     = "#1e1e2e";
      url_color             = "#f5e0dc";

     # Black
      color0  = "#45475a"; color8  = "#585b70";
     # Red
      color1  = "#f38ba8"; color9  = "#f38ba8";
     # Green
      color2  = "#a6e3a1"; color10 = "#a6e3a1";
     # Yellow
      color3  = "#f9e2af"; color11 = "#f9e2af";
     # Blue
      color4  = "#89b4fa"; color12 = "#89b4fa";
     # Magenta/Mauve
      color5  = "#f5c2e7"; color13 = "#f5c2e7";
     # Teal
      color6  = "#94e2d5"; color14 = "#94e2d5";
     # White
      color7  = "#bac2de"; color15 = "#a6adc8";

     # Window
      background_opacity    = "0.6";
      window_padding_width  = 12;
      confirm_os_window_close = 0;

     # Cursor
      cursor_shape          = "beam";
      cursor_blink_interval = "0.5";

     # Misc
      enable_audio_bell = "no";
    };
  };
}
