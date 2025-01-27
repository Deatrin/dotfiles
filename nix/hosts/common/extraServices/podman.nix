{pkgs, ...}: {
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [
          "--filter=until-24h"
          "--filter=label!=important"
        ];
      };
      defaultnetwork.settings.dns_enableds = true;
    };
  };
  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
