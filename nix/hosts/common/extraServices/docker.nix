{pkgs, ...}: {
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [
          "--filter=until-24h"
          "--filter=label!=important"
        ];
      };
    };
  };
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
