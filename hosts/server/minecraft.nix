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
        # Vanilla Perfected, build "Tiny Takeover Hotfix 3.0" (1.0.3+26.1.2),
        # the current release for Minecraft 26.1.2 / Fabric as of July 2026.
        # https://modrinth.com/modpack/vanilla-perfected/version/1.0.3+26.1.2
        modpack = pkgs.fetchModrinthModpack {
          url = "https://cdn.modrinth.com/data/1ocGzRHv/versions/zCNpmrT6/Vanilla%20Perfected%201.0.3%2B26.1.2.mrpack";
          # First build will fail with a hash mismatch and print the real
          # value to use here - copy that in and rebuild. See note below.
          packHash = pkgs.lib.fakeHash;
          side = "server";
        };
      in
      {
        enable = true;
        autoStart = true;

        package = pkgs.fabricServers.fabric-26_1_2.override {
          jre_headless = pkgs.temurin-jre-bin-25;
          loaderVersion = "0.19.2";
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
