{config, ...}: {
  imports = [
    ../common
    ../features/cli
    ./home-server.nix
  ];
}
