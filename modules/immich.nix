{ config, pkgs, ... }:
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    mediaLocation = "/var/lib/immich-pictures";
    accelerationDevices = null; # Access to all devices for hardware transcoding
    
    database = {
      enable = true;
      createDB = true;
    };
    
    environment = {
      PUBLIC_LOGIN_PAGE_MESSAGE = "ルース家写真";
      LOG_LEVEL = "log";
    };
  };

  # Add immich user to video/render groups for hardware acceleration
  users.users.immich.extraGroups = [ "video" "render" ];

  # Install Immich CLI for importing
  environment.systemPackages = with pkgs; [
    immich-cli
  ];

  networking.firewall.allowedTCPPorts = [ 2283 ];
}