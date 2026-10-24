{pkgs, ...}: {
  programs.nvf = {
    enable = true;
    defaultEditor = true;

    settings.vim = {
      package = pkgs.unstable.neovim-unwrapped;

      keymaps = [
        {
          mode = "n";
          key = "<leader>rp";
          action = ":lua require('precognition').peek()<CR>";
          desc = "Peek recognition";
        }
        {
          key = "<leader>pv";
          mode = "n";
          silent = true;
          action = ":Neotree<Cr>";
        }
        {
          key = "<leader>pt";
          mode = "n";
          silent = true;
          action = ":Neotree toggle<Cr>";
        }
        # Telescope keys
        {
          key = "<leader><leader>";
          mode = "n";
          silent = true;
          action = ":Telescope buffers<Cr>";
          desc = "[ ] Find existing buffers";
        }
        {
          key = "<leader>s.";
          mode = "n";
          silent = true;
          action = ":Telescope oldfiles<Cr>";
          desc = "[S]earch Recent Files (. for repeat)";
        }
        {
          key = "<leader>sr";
          mode = "n";
          silent = true;
          action = ":Telescope resume<Cr>";
          desc = "[S]earch [R]esume";
        }
        {
          key = "<leader>sd";
          mode = "n";
          silent = true;
          action = ":Telescope diagnostics<Cr>";
          desc = "[S]earch [D]iagnostics";
        }
        {
          key = "<leader>sg";
          mode = "n";
          silent = true;
          action = ":Telescope live_grep<Cr>";
          desc = "[S]earch by [G]rep";
        }
        {
          key = "<leader>sw";
          mode = "n";
          silent = true;
          action = ":Telescope grep_string<Cr>";
          desc = "[S]earch current [W]ord";
        }
        {
          key = "<leader>ss";
          mode = "n";
          silent = true;
          action = ":Telescope builtin<Cr>";
          desc = "[S]earch [S]elect Telescope";
        }
        {
          key = "<leader>sf";
          mode = "n";
          silent = true;
          action = ":Telescope find_files<Cr>";
          desc = "[S]earch [F]iles";
        }
        {
          key = "<leader>sk";
          mode = "n";
          silent = true;
          action = ":Telescope keymaps<Cr>";
          desc = "[S]earch [K]eymaps";
        }
        {
          key = "<leader>sh";
          mode = "n";
          silent = true;
          action = ":Telescope help_tags<Cr>";
          desc = "[S]earch [H]elp";
        }
        # CodeCompanion (Ollama)
        {
          key = "<leader>ac";
          mode = "n";
          silent = true;
          action = ":CodeCompanionChat<CR>";
          desc = "[A]I [C]hat";
        }
        {
          key = "<leader>ac";
          mode = "v";
          silent = true;
          action = ":CodeCompanionChat Add<CR>";
          desc = "[A]I [C]hat add selection";
        }
        {
          key = "<leader>aa";
          mode = ["n" "v"];
          silent = true;
          action = ":CodeCompanionActions<CR>";
          desc = "[A]I [A]ctions";
        }
      ];
      viAlias = false;
      vimAlias = true;

      lsp = {
        enable = true;
        formatOnSave = true;
        trouble.enable = true;
        lspSignature.enable = true;
      };

      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        nix = {
          enable = true;
          # Pinned rather than relying on nvf's default, so format-on-save
          # always matches `nix fmt` (flake/packages.nix).
          format.type = ["alejandra"];
        };
        markdown.enable = true;
        bash.enable = true;
        go.enable = true;
        html.enable = false;
        helm.enable = true;
        kotlin.enable = true;
        python.enable = true;
        sql.enable = true;
        terraform.enable = true;
        yaml.enable = true;
      };

      visuals = {
        nvim-scrollbar.enable = true;
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        fidget-nvim.enable = true;
        highlight-undo.enable = true;
        indent-blankline.enable = true;
      };

      statusline = {
        lualine = {
          enable = true;
          setupOpts.options.theme = "tokyonight";
          integrations.breadcrumbs = {
            nvim-navic.enable = true;
            navbuddy.enable = true;
          };
        };
      };

      theme = {
        enable = true;
        name = "tokyonight";
        style = "night";
        # transparent = false;
      };

      autopairs.nvim-autopairs.enable = true;
      autocomplete.nvim-cmp.enable = true;
      snippets.luasnip.enable = true;
      filetree.neo-tree.enable = true;
      tabline.nvimBufferline.enable = true;
      treesitter.context.enable = true;

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      telescope.enable = true;

      git = {
        enable = true;
        gitsigns = {
          enable = true;
          codeActions.enable = true;
        };
      };

      notify = {
        nvim-notify.enable = true;
      };

      projects = {
        project-nvim.enable = true;
      };

      utility = {
        surround.enable = true;
        diffview-nvim.enable = true;
        motion = {
          hop.enable = true;
          leap.enable = true;
        };
      };

      notes = {
        todo-comments.enable = true;
      };

      terminal = {
        toggleterm = {
          enable = true;
          lazygit.enable = true;
        };
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        illuminate.enable = true;
      };

      extraPlugins = with pkgs.unstable.vimPlugins; {
        render-markdown = {
          package = render-markdown-nvim;
          setup = ''
            require('render-markdown').setup({
              heading = { enabled = true },
              code = { enabled = true, style = "full" },
              bullet = { enabled = true },
              checkbox = { enabled = true },
              table = { enabled = true },
            })
          '';
        };

        codecompanion = {
          package = codecompanion-nvim;
          setup = ''
            require('codecompanion').setup({
              strategies = {
                chat   = { adapter = 'ollama' },
                inline = { adapter = 'ollama' },
              },
            })
          '';
        };
      };

      comments = {
        comment-nvim.enable = true;
      };
    };
  };
}
