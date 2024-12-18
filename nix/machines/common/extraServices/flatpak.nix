{pkgs, ...}: {
  services.flatpak.enable = true;
  xdg.portal = {
    # xdg desktop intergration (required for flatpak)
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
