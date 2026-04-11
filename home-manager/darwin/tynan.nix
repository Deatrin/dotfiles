{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  imports = [
    ../common/global
    ../common/features/cli/ghostty.nix
    ../common/features/cli/opnix_personal.nix
    ../common/features/dev
    ../common/features/kubernetes
  ];

  home = {
    username = lib.mkDefault "deatrin";
    homeDirectory = lib.mkDefault "/Users/${config.home.username}";
    stateVersion = lib.mkDefault "24.05";
  };

  home.packages = with pkgs; [
    terminal-notifier # send notifications to macOS notification center
  ];

  # OpenCode — Ollama provider config
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
}
