{config, ...}: {
  networking.wg-quick.interfaces = {
    DE = {
      configFile = config.age.secrets.wg-DE.path;
      autostart = false;
  };
  services.resolved.enable = true;
}
