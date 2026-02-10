{ config, ... }:
{
  sops.secrets.porkbun-api-key = { };
  sops.secrets.porkbun-secret-key = { };

  sops.templates."ddns-config.json" = {
    path = "/etc/ddns-updater/config.json";
    owner = "ddns-updater";
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

  services.ddns-updater = {
    enable = true;
    environment = {
      CONFIG_FILEPATH = "/etc/ddns-updater/config.json";
      SERVER_ENABLED = "no";
      PERIOD = "5m";
    };
  };
}
