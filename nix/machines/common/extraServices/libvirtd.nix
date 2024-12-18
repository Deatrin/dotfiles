{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.extraServices.libvirtd;
in {
  options.extraServices.libvirtd.enable = mkEnableOption "enable libvirtd";

  config = mkIf cfg.enable {
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [pkgs.OVMFFull];
          };
        };
      };
    };
    programs.virt-manager.enable = true;
  };
}