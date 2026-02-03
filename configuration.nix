{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # sops
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };

  # Networking
  networking = {
    hostName = "home-server";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [ 22 80 443 8080 ];
      allowedUDPPorts = [ ];
    };
  };

  # Locale
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "jp106";
  services.xserver.xkb.layout = "jp";

  # User
  users.users.sean = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
  };
  # No Sudo
  nix.settings.allowed-users = [ "@wheel" ];

  # Hardware acceleration (Intel N100)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
    ];
  };

  # Packages
  environment.systemPackages = with pkgs; [
    wget git gh vim htop btop docker-compose tree erdtree
  ];

  # Docker
  virtualisation.docker.enable = true;

  # SSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
