{ config, pkgs, ... }:
{
  # Install borg
  environment.systemPackages = with pkgs; [ borgbackup ];

  # Borg backup to USB SSD
  services.borgbackup.jobs."immich-to-ssd" = {
    paths = [ config.services.immich.mediaLocation ];
    repo = "/ssd/backups/immich";
    startAt = "daily";
    compression = "zstd,3";  # Good compression, fast
    encryption.mode = "none";  # No encryption for local backup
    
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 3;
    };
    
    # Run after backup completes
    postHook = ''
      echo "Backup completed at $(date)" >> /var/log/borg-backup.log
    '';
  };
}