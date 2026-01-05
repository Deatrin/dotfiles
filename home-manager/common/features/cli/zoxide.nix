{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = false;  # Manually init after fzf-tab loads
    options = ["--cmd cd"];
  };
}
