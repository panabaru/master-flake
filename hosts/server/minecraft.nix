{ inputs, pkgs, ... }:
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = "/srv/minecraft";
  

    servers.modded = {
      enable = true;
      autoStart = true;

      package = pkgs.fabricServers.fabric-26_1_2.override {
        jre_headless = pkgs.temurin-jre-bin-25;
        loaderVersion = "0.19.2";
      };
      jvmOpts = "-Xms2G -Xmx8G";

      serverProperties = {
        server-port = 25565;
        difficulty = 3;
        gamemode = 0;
        max-players = 3;
        motd = "Vanilla Prrrfected";
        white-list = false;
        enable-rcon = true;
        "rcon.password" = "@rcon_password@";
      };

      operators = {
        graintrain = "168a0ea4-556b-47e8-b454-9df60a62cbc9";
      };
    };
  };
}
