# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "tachi"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  networking = {
    interfaces.enp0s31f6.ipv4.addresses = [
      {
        address = "10.1.10.220";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.1.10.1";
    nameservers = ["10.1.10.220""1.1.1.1"];
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    git
    nfs-utils
    yubikey-personalization
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.pcscd.enable = true;
  services.yubikey-agent.enable = true;
  programs.ssh.startAgent = false;

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
    allowSFTP = true;
    ports = [2222];
  };

  programs.zsh.enable = true;

  # Automatic Updating
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "weekly";

  # Automatic cleanup
  nix.settings.auto-optimise-store = true;

  fileSystems."/home/deatrin/docker_volumes/paperless-prod-1/paperless_data" = {
    device = "10.1.10.5:/volume1/kubedata/paperless_data";
    fsType = "nfs";
    options = [
      "rw"
      "nolock"
    ];
  };

  fileSystems."/home/deatrin/docker_volumes/immich-prod-1/Library" = {
    device = "10.1.10.5:/volume1/kubedata/Photos";
    fsType = "nfs";
    options = [
      "rw"
      "nolock"
    ];
  };

  fileSystems."/home/deatrin/docker_volumes/navidrome-prod-1/library" = {
    device = "10.1.10.5:/volume1/kubedata/media/music";
    fsType = "nfs";
    options = [
      "rw"
      "nolock"
    ];
  };

  fileSystems."/home/deatrin/docker_volumes/audiobookshelf-prod-1/library" = {
    device = "10.1.10.5:/volume1/kubedata/audiobookshelf";
    fsType = "nfs";
    options = [
      "rw"
      "nolock"
    ];
  };

  fileSystems."/home/deatrin/docker_volumes/arr-stack-prod-1/data" = {
    device = "10.1.10.5:/volume1/kubedata/media";
    fsType = "nfs";
    options = [
      "rw"
      "nolock"
    ];
  };

  fileSystems."/home/deatrin/docker_volumes/calibre-prod-1/books" = {
    device = "10.1.10.5:/volume1/kubedata/books";
    fsType = "nfs";
    options = [
      "rw"
      "nolock"
    ];
  };

  fileSystems."/home/deatrin/docker_volumes/netbox-prod-1/config" = {
    device = "10.1.10.5:/volume1/kubedata/Netbox";
    fsType = "nfs";
    options = [
      "rw"
      "nolock"
    ];
  };


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
