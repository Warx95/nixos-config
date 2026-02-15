{ config, pkgs, ... }:

{
  ################################
  # Basic system settings
  ################################

  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "cosmic-host";

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  ################################
  # Bootloader: GRUB + UEFI
  ################################

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";

    # Install to fallback path as removable media too
    efiInstallAsRemovable = true;

    # Put GRUB into the ESP mounted at /boot (what disko set up)
    # This ensures /boot/EFI/BOOT/BOOTX64.EFI is created.
    useOSProber = false;
  };

  ################################
  # Filesystems (btrfs options live in disko layout)
  ################################

  # disko already created /, /home, /nix subvolumes & mounted them.
  # hardware-configuration.nix will refer to /dev/disk/by-uuid/*

  ################################
  # ZRAM swap
  ################################

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    # With 32GB RAM, 50% is a sane default; tune later if desired.
    memoryPercent = 50;
    priority = 100;
  };

  ################################
  # COSMIC Desktop
  ################################

  services.xserver.enable = true;
  services.displayManager.gdm.enable = false; # explicit off

  # Wayland + COSMIC
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;

  # Enable PipeWire for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Wayland-friendly settings
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  ################################
  # NVIDIA (RTX 4080, Wayland)
  ################################

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = true;
    nvidiaSettings = true;
  };

  ################################
  # Users
  ################################

  users.users.rusantokhin = {
    isNormalUser = true;
    description = "Main user";
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";
  };

  security.sudo.wheelNeedsPassword = true;

  ################################
  # Networking
  ################################

  networking.networkmanager.enable = true;

  ################################
  # Misc
  ################################

  services.printing.enable = false;
  
  ################################
  # Programs
  ################################
  
  environment.systemPackages = with pkgs; [
  git
  ];

  system.stateVersion = "25.11";
}
