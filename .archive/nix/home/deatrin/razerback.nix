{config, ...}: {
  imports = [
    ../common
    ../features/cli
    ../features/desktop
    ./home.nix
  ];
}
