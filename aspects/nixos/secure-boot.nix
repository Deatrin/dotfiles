{
  flake.modules.nixos.secure-boot = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: let
    cfg = config.dotfiles.secure-boot;
  in {
    # Imported unconditionally so the boot.lanzaboote options exist; inert
    # unless enabled below.
    imports = [inputs.lanzaboote.nixosModules.lanzaboote];

    options.dotfiles.secure-boot.enable = lib.mkEnableOption ''
      Secure Boot via lanzaboote (signed systemd-boot + UKIs).
      The sbctl keys must already exist in /var/lib/sbctl before enabling, or
      the bootloader install fails. sbctl itself is only installed once this
      is on, so create them with it from nixpkgs (`nix shell nixpkgs#sbctl`,
      then `sudo "$(command -v sbctl)" create-keys`). Key enrollment into the
      firmware is a manual step; see hosts/nixos/artemis/REINSTALL.md
      section 4'';

    config = lib.mkIf cfg.enable {
      # lanzaboote replaces the systemd-boot module. It still reads
      # systemd-boot.configurationLimit/consoleMode/editor for its defaults.
      boot.loader.systemd-boot.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };

      # Enrollment and `sbctl verify` / `sbctl status` (key creation has to
      # happen before this is installed; see the option description).
      environment.systemPackages = [pkgs.sbctl];
    };
  };
}
