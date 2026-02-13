{ config, pkgs, ... }:
{
  systemd.services.remote-reboot = {
    description = "UDP reboot listener";
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.socat}/bin/socat UDP-LISTEN:9999,fork EXEC:'${pkgs.systemd}/bin/reboot'
    '';
    serviceConfig = {
      Restart = "always";
    };
  };

  networking.firewall.allowedUDPPorts = [ 9999 ];
}