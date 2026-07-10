{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.mergerfs pkgs.restic ];

  # ── Local drive mounts ──────────────────────────────────────────────
  fileSystems."/mnt/disks/mediadisk1" = {
    device = "/dev/disk/by-label/mediadisk1";
    fsType = "ext4";
    options = [ "nofail" ];
  };
  fileSystems."/mnt/disks/mediadisk2" = {
    device = "/dev/disk/by-label/mediadisk2";
    fsType = "ext4";
    options = [ "nofail" ];
  };
  fileSystems."/mnt/disks/vault-backup" = {
    device = "/dev/disk/by-label/vaultbackup";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  # A plain directory on the system NVMe, contributed as a pool branch —
  # not a separate mount, just some of the root filesystem's free space.
  systemd.tmpfiles.rules = [
    "d /mnt/disks/nvme-share 2775 root media -"
  ];

  # ── The media pool: sda + sdb + a slice of the NVMe ─────────────────
  # sdc is deliberately excluded — it's the dedicated backup drive below.
  fileSystems."/data/media" = {
    depends = [ "/mnt/disks/mediadisk1" "/mnt/disks/mediadisk2" ];
    device = "/mnt/disks/mediadisk1:/mnt/disks/mediadisk2:/mnt/disks/nvme-share";
    fsType = "mergerfs";
    options = [
      "defaults"
      "category.create=mfs"  # new files go wherever has the most free space
      "minfreespace=50G"    # ...but never below this floor, on any branch
      "allow_other"
      "use_ino"
      "fsname=mergerfs-media"
    ];
  };

  # ── Obsidian vault backups → dedicated USB drive (sdc), versioned ────
  services.restic.backups.couchdb-vaults = {
    initialize = true; # creates the backup repo on the drive the first time this runs
    paths = [ "/var/lib/couchdb" ];
    repository = "/mnt/disks/vault-backup/restic-repo";
    passwordFile = "/etc/restic-backup-password"; # lives only on the server — same idea as the CouchDB admin password, never in the repo
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true; # catches up if the server was off when a run was due
    };
    pruneOpts = [
      "--keep-hourly 48"  # every hourly snapshot for the last 2 days
      "--keep-daily 14"   # one snapshot per day going back 2 weeks
      "--keep-weekly 8"   # one snapshot per week going back 2 months
    ];
  };
}
