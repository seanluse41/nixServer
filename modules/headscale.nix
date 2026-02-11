{ config, pkgs, ... }:
{
  services.headscale = {
    enable = true;
    address = "127.0.0.1";
    port = 8085;
    settings = {
      server_url = "https://headscale.zoocom.homes";
      dns = {
        base_domain = "hs.net";  # must NOT be a substring of server_url
        magic_dns = true;
        nameservers.global = [ "1.1.1.1" "8.8.8.8" ];
      };
      logtail.enabled = false;
    };
  };

  environment.systemPackages = [ config.services.headscale.package ];

  services.nginx = {
    enable = true;
    virtualHosts."headscale.zoocom.homes" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
        proxyWebsockets = true;
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "seanluse41@gmail.com";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}