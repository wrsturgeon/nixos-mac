{ config, pkgs, ... }: let
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
  hyprland = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/master.tar.gz"
  }).defaultNix;
in {
  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };
  environment.systemPackages = with pkgs; [
    helix
    gitFull
  ];
  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation {
      name = "brcm-firmware";
      buildCommand = ''
        dir="$out/lib/firmware"
        mkdir -p "$dir"
        cp -r ${./firmware}/* "$dir"
      '';
    })
  ];
  i18n.defaultLocale = "en_US.UTF-8";
  imports = [
    ./hardware-configuration.nix
    "${builtins.fetchGit { url = "https://github.com/kekrby/nixos-hardware.git"; }}/apple/t2"
    hyprland.nixosModules.default
  ];
  networking = {
    hostName = "macbook-nixos";
    networkmanager.enable = true;
  };
  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    package = pkgs.nixUnstable;
    settings.experimental-features = [ "flakes" "nix-command" ];
  };
  nixpkgs = {
    config.allowUnfree = true; # :_(
    overlays = [ hyprland.overlays.default ];
  };
  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;
      config.credential.helper = "libsecret";
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    hyprland = {
      enable = true;
      package = pkgs.hyprland;
    };
    mtr.enable = true;
  };
  services = {
    openssh.enable = true;
    xserver = {
      # desktopManager.gnome.enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      enable = true;
      layout = "us";
      libinput.enable = true;
    };
  };
  system = {
    autoUpgrade = {
      dates = "04:00";
      enable = true;
      flags = [ "--update-input" "nixpkgs" ];
      allowReboot = true;
    };
    copySystemConfiguration = true;
    stateVersion = "23.05";
  };
  time.timeZone = "America/Los_Angeles";
  users.users.will = {
    description = "Will";
    extraGroups = [ "networkmanager" "wheel" ];
    isNormalUser = true;
    packages = with pkgs; [
      firefox
    ];
  };
}
