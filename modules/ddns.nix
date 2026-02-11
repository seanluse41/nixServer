{ config, lib, ... }:
{
  sops.secrets.porkbun-api-key = { };
  sops.secrets.porkbun-secret-key = { };

  users.users.ddns-updater = {
    isSystemUser = true;
    group = "ddns-updater";
  };
  users.groups.ddns-updater = { };

  sops.templates."ddns-config.json" = {
    path = "/etc/ddns-updater/config.json";
    owner = "ddns-updater";
    group = "ddns-updater";
    mode = "0440";
    content = ''
      {
        "settings": [
          {
            "provider": "porkbun",
            "domain": "zoocom.homes",
            "host": "headscale",
            "api_key": "${config.sops.placeholder.porkbun-api-key}",
            "secret_api_key": "${config.sops.placeholder.porkbun-secret-key}"
          }
        ]
      }
    '';
  };

  systemd.services.ddns-updater.serviceConfig.DynamicUser = lib.mkForce false;

  services.ddns-updater = {
    enable = true;
    environment = {
      CONFIG_FILEPATH = "/etc/ddns-updater/config.json";
      SERVER_ENABLED = "no";
      PERIOD = "5m";
    };
  };
}