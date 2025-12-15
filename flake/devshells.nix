{inputs, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    pkgs-unstable,
    system,
    lib,
    ...
  }: {
    devShells = {
      # Default shell for dotfiles development
      default = pkgs.mkShell {
        name = "dotfiles-dev";
        packages = with pkgs; [
          # Nix development tools (stable)
          nixd
          nixfmt-rfc-style
          nix-tree
          nvd
          statix
          deadnix
          manix

          # Build tools
          nixos-rebuild
          home-manager
          nh
        ];

        shellHook = ''
          echo "🔧 Dotfiles Development Environment"
          echo "   Nix tools: nixd, nixfmt-rfc-style, statix, deadnix"
          echo "   Build: nixos-rebuild, home-manager, nh"
          if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "   darwin-rebuild available via nix-darwin"
          fi
          echo ""
        '';
      };

      # Go development environment
      go = pkgs.mkShell {
        name = "go-dev";
        packages = with pkgs-unstable; [
          go
          gopls
          gotools
          go-task
          golangci-lint
          delve
          gomodifytags
          gotests
          golines
          gofumpt
        ];

        shellHook = ''
          echo "🐹 Go Development Environment"
          export GOPATH="$HOME/go"
          export PATH="$GOPATH/bin:$PATH"
          echo "   GOPATH=$GOPATH"
          echo "   Go version: $(go version)"
          echo ""
        '';
      };

      # Kubernetes and infrastructure development
      kubernetes = pkgs.mkShell {
        name = "kubernetes-dev";
        packages = with pkgs-unstable;
          [
            # Core Kubernetes
            kubectl
            kubernetes-helm
            kustomize
            fluxcd
            talosctl
            k9s

            # Development clusters
            kind
            minikube

            # Kubectl plugins & utilities
            krew
            kubectx # Provides both kubectx and kubens
            stern
            kail

            # Terraform/OpenTofu
            opentofu
            terragrunt
            tflint
            terraform-docs
          ]
          ++ [
            pkgs.kubectl-browse-pvc # Custom package from stable
          ];

        shellHook = ''
          echo "☸️  Kubernetes Development Environment"
          export KUBECONFIG="''${KUBECONFIG:-$HOME/.kube/config}"
          echo "   KUBECONFIG=$KUBECONFIG"
          if command -v kubectl &>/dev/null; then
            echo "   kubectl version: $(kubectl version --client --short 2>/dev/null || echo 'N/A')"
          fi
          echo ""
        '';
      };

      # Python development environment
      python = pkgs.mkShell {
        name = "python-dev";
        packages = with pkgs-unstable;
          [
            python3
            poetry
            pipenv
            black
            ruff
            mypy
          ]
          ++ (with pkgs-unstable.python3Packages; [
            pip
            setuptools
            wheel
            pytest
            ipython
          ]);

        shellHook = ''
          echo "🐍 Python Development Environment"
          export PYTHONPATH="''${PYTHONPATH:+$PYTHONPATH:}$PWD"
          echo "   Python version: $(python --version)"
          if command -v poetry &>/dev/null; then
            echo "   Poetry: $(poetry --version 2>/dev/null || echo 'N/A')"
          fi
          echo ""
        '';
      };

      # Container and Docker development
      containers = pkgs.mkShell {
        name = "container-dev";
        packages = with pkgs-unstable; [
          docker-compose
          docker-buildx
          hadolint
          dive
          skopeo
          buildah
          podman
          compose2nix

          # Container debugging tools
          ctop
          lazydocker
        ];

        shellHook = ''
          echo "🐳 Container Development Environment"
          echo "   Tools: docker-compose, buildah, podman, hadolint, dive"
          echo "   Linting: hadolint <Dockerfile>"
          echo "   Analysis: dive <image>"
          echo ""
        '';
      };

      # Shell scripting development
      shell = pkgs.mkShell {
        name = "shell-dev";
        packages = with pkgs; [
          # Shell development
          shellcheck
          shfmt
          bash-language-server

          # Data manipulation (stable - already in use)
          jq
          yq
          sd
          ripgrep
          fd

          # Testing
          bats
        ];

        shellHook = ''
          echo "🐚 Shell Scripting Environment"
          echo "   Linting: shellcheck <script.sh>"
          echo "   Format: shfmt -w <script.sh>"
          echo "   LSP: bash-language-server"
          echo ""
        '';
      };
    };
  };
}
