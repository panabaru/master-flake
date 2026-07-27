{ inputs, pkgs, ... }:
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = "/srv/minecraft";

    servers.modded =
      let
        # Vanilla Perfected, build "Chaos Cubed Hotfix 3.0" (1.0.3+26.2),
        # the current release for Minecraft 26.2 / Fabric as of July 2026.
        # Get the download link from:
        # https://modrinth.com/modpack/vanilla-perfected/versions
        # (right-click the "Chaos Cubed Hotfix 3.0" Download button -> copy link)
        modpack = pkgs.fetchModrinthModpack {
          url = "https://cdn.modrinth.com/data/1ocGzRHv/versions/Bu8RKHri/Vanilla%20Perfected%201.0.0%2B26.3.mrpack?mr_download_reason=standalone";
          # Same trick as last time: first build fails with a hash mismatch
          # and prints the real value - copy that in and rebuild.
          packHash = pkgs.lib.fakeHash;
          side = "server";
        };
      in
      {
        enable = true;
        autoStart = true;

        package = pkgs.fabricServers.fabric-26_2.override {
          jre_headless = pkgs.temurin-jre-bin-25; # 26.2 still requires Java 25, same as 26.1
          loaderVersion = "0.19.3"; # minimum recommended loader for 26.2
        };
        jvmOpts = "-Xms2G -Xmx8G";

        # This is what was missing: without it, the server has the Fabric
        # loader but none of Vanilla Perfected's actual mods installed.
        symlinks = {
          "mods" = "${modpack}/mods";
        };
        files = {
          "config" = "${modpack}/config";
        };

        serverProperties = {
          server-port = 25565;
          difficulty = 3;
          gamemode = 0;
          max-players = 3;
          motd = "Vanilla Prrrfected";
          white-list = false;
          enable-rcon = true;
          # Was "rcon-password" (hyphen) - Minecraft only recognizes the
          # dotted key below. With the hyphen, this line was written into
          # server.properties but silently ignored, leaving RCON's real
          # password empty.
          "rcon.password" = "@rcon_password@";
        };

        operators = {
          graintrain = "168a0ea4-556b-47e8-b454-9df60a62cbc9";
        };
      };
  };
}
