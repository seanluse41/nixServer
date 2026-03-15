# modules/transmission.nix
{ config, ... }:
{
  services.transmission = {
    enable = true;
    openFirewall = true;
    settings = {
      download-dir = "/ssd/media/movies";
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = false;
    };
  };
}