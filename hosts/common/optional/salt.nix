{
  config,
  pkgs,
  ...
}: {
  services = {
    salt.master.enable = true;
  };
}
