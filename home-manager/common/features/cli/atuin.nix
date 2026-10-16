{pkgs, ...}: {
  programs.atuin = {
    enable = true;
    # Stable on purpose: unstable atuin 18.23.0's e2e_capture test
    # (filtered_commands_leave_no_captured_output) times out in the build sandbox,
    # so the build fails. Switch back to pkgs.unstable.atuin once nixpkgs fixes it.
    package = pkgs.atuin;

    flags = ["--disable-up-arrow"];

    settings = {
      auto_sync = true;
      sync_frequency = "1h";
      search_mode = "fuzzy";
      sync.records = true;
    };
  };
}
