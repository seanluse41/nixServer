{ config, pkgs, ... }:
let
  consts = import ./consts.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./modules/tailscale.nix
    ./modules/immich.nix
    ./modules/ethernet-watchdog.nix
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

  networking = {
    hostName = "home-server";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [
        consts.ports.ssh
        consts.ports.http
        consts.ports.https
        consts.ports.immich
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

  # garbage
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nix.settings.auto-optimise-store = true;

  # Limit systemd journal size
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    MaxRetentionSec=3day
  '';

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
