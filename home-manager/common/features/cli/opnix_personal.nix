{
  programs.onepassword-secrets = {
    enable = true;
    secrets = {
      # Add personal secrets here
      example = {
        path = ".config/personal-app/.env";
        reference = "op://Darwin Secrets/testenv/text";
        mode = "0600";
      };
    };
  };
}
