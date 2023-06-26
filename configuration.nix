{ config, pkgs, ... }: {
  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };
  console.font = "ter-v32n";
  environment.systemPackages = with pkgs; [
    helix
    git
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
  ];
  network = {
    hostName = "macbook-nixos";
    networkmanager.enable = true;
  };
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    mtr.enable = true;
  };
  services = {
    openssh.enable = true;
    xserver = {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      enable = true;
      layout = "us";
      libinput.enable = true;
    };
  };
  system = {
    autoUpgrade.enable = true;
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
