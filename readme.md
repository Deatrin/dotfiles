# Setup

- First sign into Appstore for MAS to work
- Start by downloading nix be using the following command

    ``` shell
    sh <(curl -L https://nixos.org/nix/install)
    ```

- Download config from github

    ``` shell
    nix-shell -p git --run 'git clone https://github.com/Deatrin/dorfiles.git ./Development/dotfiles
    ```

- Run the config with nix

    ``` shell
    nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ~/Development/dotfiles/nix/darwin#intel
    ```