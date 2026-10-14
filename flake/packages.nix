{...}: {
  perSystem = {pkgs, ...}: {
    packages = import ../pkgs {inherit pkgs;};

    # `nix fmt` formats the repo with alejandra (the style most files use).
    # Nix runs the formatter with no arguments, which alejandra treats as
    # "read stdin", so add "." whenever no path was given (flags like
    # --check alone still count as "no path").
    formatter = pkgs.writeShellApplication {
      name = "alejandra-repo";
      runtimeInputs = [pkgs.alejandra];
      text = ''
        has_path=0
        for arg in "$@"; do
          case "$arg" in
            -*) ;;
            *) has_path=1 ;;
          esac
        done
        if [ "$has_path" -eq 0 ]; then
          set -- "$@" .
        fi
        exec alejandra "$@"
      '';
    };
  };
}
