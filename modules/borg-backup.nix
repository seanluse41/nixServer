{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ borgbackup ];

  services.borgbackup.jobs."immich-to-ssd" = {
    paths = [ "/var/lib/immich-pictures" ];
    repo = "/ssd/backups/immich";
    startAt = "weekly";  # Every Sunday at midnight
    compression = "zstd,3";
    encryption.mode = "none";
    
    prune.keep = {
      weekly = 4;  # Keep last 4 weeks
    };
    
    postHook = ''
      echo "Backup completed at $(date)" >> /var/log/borg-backup.log
    '';
  };
}