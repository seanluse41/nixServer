{ config, pkgs, ... }:
let
  consts = import ../consts.nix;
  ssdPushUrl = "http://localhost:3001/api/push/7A0I8FgFnTB40XNRkEG93OfpxOVhKHow";
  piPushUrl = "http://localhost:3001/api/push/P24iryj91s7X4bN57ZvVrbMzA2prL7b1";
in
{
  environment.systemPackages = with pkgs; [ borgbackup ];

  services.borgbackup.jobs."immich-to-ssd" = {
    paths = [ "/var/lib/immich-pictures" ];
    repo = "/ssd/backups/immich";
    startAt = "weekly";
    compression = "zstd,3";
    encryption.mode = "none";

    prune.keep = {
      weekly = 4;
    };

    postHook = ''
      LOG_MSG="Backup completed at $(date)"
      echo "$LOG_MSG" >> /var/log/borg-backup.log
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "${ssdPushUrl}?status=up&msg=$LOG_MSG" || true
    '';
    
    postFail = ''
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "${ssdPushUrl}?status=down&msg=Backup failed" || true
    '';
  };

  services.borgbackup.jobs."immich-to-pi" = {
    paths = [ "/var/lib/immich-pictures" ];
    repo = "${consts.user}@${consts.network.pi256}:/home/${consts.user}/immich-backup";
    startAt = "monthly";
    compression = "zstd,3";
    encryption.mode = "none";

    prune.keep = {
      monthly = 3;
    };

    postHook = ''
      LOG_MSG="Pi backup completed at $(date)"
      echo "$LOG_MSG" >> /var/log/borg-backup.log
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "${piPushUrl}?status=up&msg=$LOG_MSG" || true
    '';
    
    postFail = ''
      ${pkgs.curl}/bin/curl -fsS -m 10 --retry 3 "${piPushUrl}?status=down&msg=Pi backup failed" || true
    '';
  };
}