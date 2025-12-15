{
  programs.onepassword-secrets = {
    enable = true;
    secrets = {
      shellSecrets = {
        path = ".config/shell-secrets/env";
        reference = "op://Darwin Secrets/testenv/text";
      };
    };
  };
}
