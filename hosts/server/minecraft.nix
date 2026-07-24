{ inputs, ... }:
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

#      package = pkgs.fabricServers.fabric-1_20_1.override {
#        loaderVersion = "0.15.11";
#      };

      jvmOpts = "-Xms2G -Xmx8G";

      serverProperties = {
        server-port = 25565;
        difficulty = 3;
        gamemode = 0;
        max-players = 3;
        motd = "Vanilla Prrrfected";
        white-list = false;
        enable-rcon = true;
        "rcon-password" = "@rcon_password@";
      };
    };
  };
}
