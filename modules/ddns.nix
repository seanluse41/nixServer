{ config, ... }:
{
  services.ddns-updater = {
    enable = true;
    settings = {
      settings = [
        {
          provider = "porkbun";
          domain = "zoocom.homes";
          host = "headscale";
          api_key = config.sops.secrets.porkbun-api-key.path;
          secret_api_key = config.sops.secrets.porkbun-secret-key.path;
        }
      ];
    };
  };

  sops.secrets.porkbun-api-key = {};
  sops.secrets.porkbun-secret-key = {};
}