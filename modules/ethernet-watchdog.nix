{ config, pkgs, ... }:
{
  systemd.services.ethernet-watchdog = {
    description = "Restart ethernet if down";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "10s";
    };
    script = ''
      while true; do
        if ! ${pkgs.iproute2}/bin/ip link show enp3s0 | grep -q "state UP"; then
          echo "Ethernet down, restarting..."
          ${pkgs.iproute2}/bin/ip link set enp3s0 down
          sleep 2
          ${pkgs.iproute2}/bin/ip link set enp3s0 up
        fi
        sleep 30
      done
    '';
  };
}