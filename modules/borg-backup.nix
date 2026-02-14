{ config, pkgs, ... }:
let
  consts = import ../consts.nix;
in
{
  environment.systemPackages = with pkgs; [ borgbackup ];

  services.borgbackup.jobs."immich-to-ssd" = {
    paths = [ "/var/lib/immich-pictures" ];
    repo = "/ssd/backups/immich";
    startAt = "weekly"; # Every Sunday at midnight
    compression = "zstd,3";
    encryption.mode = "none";

    prune.keep = {
      weekly = 4; # Keep last 4 weeks
    };

    postHook = ''
      echo "Backup completed at $(date)" >> /var/log/borg-backup.log
    '';
  };

  services.borgbackup.jobs."immich-to-pi" = {
    paths = [ "/var/lib/immich-pictures" ];
    repo = "${consts.user}@${consts.network.pi256}:/home/${consts.user}/immich-backup";
    startAt = "monthly"; # monthly 1st at midnight
    compression = "zstd,3";
    encryption.mode = "none";

    prune.keep = {
      monthly = 3; # Keep last 3 months
    };

    postHook = ''
      echo "Pi backup completed at $(date)" >> /var/log/borg-backup.log
    '';
  };
}
