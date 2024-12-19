# Setup

- First sign into Appstore for MAS to work
- Start by downloading nix be using the following command
- comment or uncomment lines 26 and 201 as needed depending on processor type

  ``` shell
  sh <(curl -L https://nixos.org/nix/install)
  ```

- Create Development Folder

``` shell
mkdir ~/Development
```

- Download config from github

  ``` shell
  nix-shell -p git --run 'git clone https://github.com/Deatrin/dotfiles.git ./Development/dotfiles
  ```

- cd down to the darwin folder
- Run the config with nix

  ``` shell
  nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake .#intel
  ```
