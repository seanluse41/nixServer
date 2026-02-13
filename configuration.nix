{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/tailscale.nix
    ./modules/immich.nix
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # sops
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };

  # build packages on desktop push to server
  nix.settings.trusted-public-keys = [
    "desktop:BhUdL4xwaKkc77fe+B7iQulMzkd5VWXSyQKZ2rnGp04="
  ];

  # Networking
  networking = {
    hostName = "home-server";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [
        22
        80
        443
        8080
      ];
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
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
    ];
  };

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
    wget
    git
    gh
    vim
    htop
    btop
    docker-compose
    tree
    erdtree
    nvd
    claude-code
  ];

  programs.bash.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake ~/nixServer#home-server && nvd diff /run/booted-system /run/current-system";
  };

  # Docker
  virtualisation.docker.enable = true;

  # SSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
