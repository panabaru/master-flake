{ config, ... }:
{
  virtualisation.podman.enable = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/musicseerr/config 0755 1000 1000 -"
    "d /var/lib/musicseerr/cache 0755 1000 1000 -"
  ];

  virtualisation.oci-containers = {
    backend = "podman";
    containers.musicseerr = {
      image = "ghcr.io/habirabbu/musicseerr:latest";
      extraOptions = [ "--network=host" ];
      volumes = [
        "/var/lib/musicseerr/config:/app/config"
        "/var/lib/musicseerr/cache:/app/cache"
      ];
      environment = {
        PUID = "1000";
	PGID = "1000";
	PORT = "8688";
        TZ = config.time.timeZone;
      };
    };
  };
}
