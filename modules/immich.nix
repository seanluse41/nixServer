{ config, pkgs, ... }:
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/home/sean/immich-pictures";
    
    # Database settings
    database = {
      enable = true;
      createDB = true;
    };
    
    # Environment variables
    environment = {
      PUBLIC_LOGIN_PAGE_MESSAGE = "ルース家写真";
      LOG_LEVEL = "log";
    };
  };

  networking.firewall.allowedTCPPorts = [ 2283 ];
}