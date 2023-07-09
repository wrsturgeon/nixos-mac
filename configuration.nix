{ config, pkgs, ... }: {
  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };
  environment.systemPackages = with pkgs; [
    gitFull
    helix
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
  };
  programs = {
    git = {
      # config.credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
      enable = true;
      package = pkgs.gitFull;
    };
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
      cargo # Rust (for `cargo new`; the project should use Nix)
      element-desktop # Matrix client
      firefox # Browser
      nil # Nix language server
      tree # Better `ls`
    ];
  };
}
