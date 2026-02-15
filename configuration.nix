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

  networking = {
    hostName = "coshmar";
    networkmanager.enable = true;
    firewall.enable = true;
    # firewall.allowedTCPPorts = [ ... ];  
  };

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";
  
  # Manual updates only
  system.autoUpgrade.enable = false;
  services.fwupd.enable = true; # Firmware updates
  # fwupdmgr get-devices
  # fwupdmgr refresh
  # fwupdmgr get-updates
  # fwupdmgr update
  
  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  
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
    
    configurationLimit = 10; # Last 10 generations
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
  # Performance
  ################################
  
  # Better for SSDs and general responsiveness
  boot.kernel.sysctl = {
    "vm.swappiness" = 180; # Higher for zram (encourages swap to compressed RAM)
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0; # Reduces swap thrashing on zram
  };
  
  # SSD TRIM for all filesystems
  services.fstrim.enable = true;
  
  # Better for NVMe drives
  boot.kernelParams = [ 
  "nvme_core.default_ps_max_latency_us=0"
  "nvidia-drm.modeset=1"
  ]; # Disable power saving

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
  # Mouse settings
  ################################
  
  services.libinput = {
    enable = true;
    mouse = {
        accelProfile = "flat";
        accelSpeed = "0.5";
        middleEmulation = false;
    };
  };
  
  ################################
  # Programs
  ################################
  
  environment.systemPackages = with pkgs; [
    # Basics
    git
    wget
    curl
    micro
    htop
    btop
    
    # System debugging
    pciutils # lspci
    usbutils # lsusb
    lshw     # hardware info
    
    # Filesystem
    btrfs-progs
    compsize # btrfs compression stats
    
    # Network debugging
    nmap
    traceroute
    
    # File management
    tree
    fd      # Modern find
    ripgrep # Modern grep
    
    # Archive handling
    unzip
    p7zip
    
    # Browsers
    firefox
    
    # Image viewer
    loupe
    
    # Archive manager
    file-roller
  ];

  ################################
  # Font settings
  ################################

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        liberation_ttf
        fira-code
        fira-code-symbols
        (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    ];
    
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "FiraCode Nerd Font" ];
        }; 
    # Better font rendering
    enable = true;
    antialias = true;
    hinting.enable = true;
    hinting.style = "slight";
    subpixel.rgba = "rgb";
    };        
  };

  ################################
  # Misc
  ################################

  services.printing.enable = false;
  
  system.stateVersion = "25.11";
}
