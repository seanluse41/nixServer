{ config, pkgs, ... }:
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/var/lib/immich-pictures";
    
    database = {
      enable = true;
      createDB = true;
    };
    
    environment = {
      PUBLIC_LOGIN_PAGE_MESSAGE = "ルース家写真";
      LOG_LEVEL = "log";
    };
  };

  # Install Immich CLI for importing
  environment.systemPackages = with pkgs; [
    immich-cli
  ];

  networking.firewall.allowedTCPPorts = [ 2283 ];
}