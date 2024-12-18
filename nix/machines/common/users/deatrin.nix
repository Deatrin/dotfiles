{
  config,
  pkgs,
  inputs,
  ...
}: {
  users.users.deatrin = {
    initialHashedPassword = "$y$j9T$PmGnK6mw4kLWTYfb3mZrM/$DHOTvVwJ.mxoeh.mU/nRfuu8D.DqVPrUBMdingTaRC7";
    isNormalUser = true;
    description = "Deatrin";
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "libvirtd"
      "flatpak"
      "audio"
      "video"
      "plugdev"
      "input"
      "kvm"
      "qemu-libvirtd"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQClJ3M0ZDNBTRPtMRkk3czMcwkTRON/7e2GOV8nx2aUttutnfDKqcM7FuD4MgkWVkk8VkUCkZmZXPjz/lNi8IHqwPCN2HBtsgSDUamXr2o99yhhVy6HxVElqMYlDkEzhqH4LWGviGalIflFdPM9P1uDxCM70QpoaA0i4lbUxeSSmV1gXevevq6BGCMb3tJ9+XMfhFKyK/fpysEYZk7Q2wWjwb6IDR4JqWxRD47XOrwgbnCL3C7jfNUysYJ4MdXlCMXRzi6wqFYbEtSPIb9uDP2G6YLYMZiu6S4DiDocnrsky7qlk9nQsFaUtApSNzJEI9TfwJ1TAE9CoQF8B3cKRE+mtX3h0HfZvlgB0cO2jkukNhY/kCHHElXkITHm90eD9TNLN1ba0KU3znHQjdi6OLD82SRP+o+H1VDEEUfIFjSmuv9Nu3CdLEhFLGyStAYsMG+kry3oEgrW++9iieDqVorcgnoj2H+NcDEGGssJxSM6GglPajSsDi+aF0S6ZWuzmnWXA9g4Rrh9inToJbKwj7+CR0YMZ484sJYFBETBpVjdANY/uOWQ8VKBS+OkWw9P3eZbeVg6zfJhvGo+vvQ++Eipwf2My+0IjvDG3lFXLNupDq6JRftDxv0UOqKHB3nb9DrrJaKQbo3A84HbI/jGR03QBL7VDXd7RlV87iF4Y2T3kw== cardno:14 836 034"
    ]; # to add more keys just and a new line and put it in quotes
    packages = [inputs.home-manager.packages.${pkgs.system}.default];
  };
  home-manager.users.deatrin =
    import ../../../home/deatrin/${config.networking.hostName}.nix;
}
