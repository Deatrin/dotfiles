# {
#   age = {
#     secrets = {
#       deatrin-secrets = {
#         file = ../../../secrets/deatrin-secrets.age;
#         owner = "deatrin";
#       };
#     };
#   };
# }
{
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
    # Ensure deatrin user has access to onepassword-secrets group
    users = ["deatrin"];

    secrets = {
      autin = {
        reference = "op://nix_secrets/atuin/username";
        mode = "0600";
      };
    };
  };
}
