# OpenCode configured to use the self-hosted Ollama on nauvoo
# (https://ollama.jennex.dev) as its model provider. The opencode CLI itself
# comes from Homebrew via the darwin dev-apps role; this only writes its
# config and a dummy auth entry (Ollama needs no real key).
{
  flake.modules.homeManager.opencode = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.opencode;
  in {
    options.dotfiles.opencode.enable = lib.mkEnableOption "OpenCode with the self-hosted Ollama provider";

    config = lib.mkIf cfg.enable {
      home.file.".config/opencode/opencode.json".text = builtins.toJSON {
        "$schema" = "https://opencode.ai/config.json";
        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama";
            options = {
              baseURL = "https://ollama.jennex.dev/v1";
            };
            models = {
              "gemma4:e4b" = {
                name = "Gemma 4 E4B";
              };
            };
          };
        };
      };

      home.file.".local/share/opencode/auth.json".text = builtins.toJSON {
        ollama = {
          type = "api";
          key = "ollama";
        };
      };
    };
  };
}
