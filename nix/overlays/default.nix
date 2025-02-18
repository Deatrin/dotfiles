{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev:
    (import ../pkgs {pkgs = final;})
    // (inputs.hyprpanel.overlay final prev)
    // {rose-pine-hyprcursor = inputs.rose-pine-hyprcursor.packages.${prev.system}.default;};
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
