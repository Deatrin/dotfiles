{inputs, ...}: {
  imports = [inputs.nvf.homeManagerModules.default];
  programs.nvf = {
    enable = true;
    settings = {
      config.vim = {
        viAlias = true;
        vimAlias = true;
        keymaps = [
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
        ];

        spellcheck = {
          enable = true;
        };

        lsp = {
          formatOnSave = true;
          lspkind.enable = false;
          lightbulb.enable = true;
          lspsaga.enable = true;
          trouble.enable = true;
          otter-nvim.enable = true;
          nvim-docs-view.enable = true;
        };

        debugger = {
          nvim-dap = {
            enable = true;
            ui.enable = true;
          };
        };

        # This section does not include a comprehensive list of available language modules.
        # To list all available language module options, please visit the nvf manual.
        languages = {
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          # Enable Languages here
          nix.enable = true;
          markdown.enable = true;
          bash.enable = true;
          css.enable = true;
          html.enable = true;
          sql.enable = true;
          go.enable = true;
          lua.enable = true;
          python.enable = true;
        };

        visuals = {
          nvim-scrollbar.enable = true;
          nvim-web-devicons.enable = true;
          nvim-cursorline.enable = true;
          cinnamon-nvim.enable = true;
          fidget-nvim.enable = true;
          highlight-undo.enable = true;
          indent-blankline.enable = true;

          # Fun
          cellular-automaton.enable = false;
        };

        statusline = {
          lualine = {
            enable = true;
            theme = "catppuccin";
          };
        };

        theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
          transparent = false;
        };

        autopairs.nvim-autopairs.enable = true;

        # nvf provides various autocomplete options. The tried and tested nvim-cmp
        # is enabled in default package, because it does not trigger a build. We
        # enable blink-cmp in maximal because it needs to build its rust fuzzy
        # matcher library.
        autocomplete = {
          blink-cmp.enable = true;
        };

        snippets.luasnip.enable = true;

        filetree = {
          neo-tree = {
            enable = true;
            setupOpts.enable_cursor_hijacking = true;
          };
        };

        tabline = {
          nvimBufferline.enable = true;
        };

        treesitter.context.enable = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
          #     hardtime-nvim.enable = true;
        };

        telescope.enable = true;

        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false; # throws an annoying debug message
        };

        minimap = {
          minimap-vim.enable = false;
          codewindow.enable = true; # lighter, faster, and uses lua for configuration
        };

        dashboard = {
          dashboard-nvim.enable = true;
        };

        notify = {
          nvim-notify.enable = true;
        };

        projects = {
          project-nvim.enable = true;
        };

        utility = {
          vim-wakatime.enable = false;
          diffview-nvim.enable = true;
          yanky-nvim.enable = true;
          surround.enable = true;
          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = true;
          };
          images = {
            image-nvim.enable = false;
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
          modes-nvim.enable = false; # the theme looks terrible with catppuccin
          illuminate.enable = true;
          breadcrumbs = {
            enable = true;
            navbuddy.enable = true;
          };
          smartcolumn = {
            enable = true;
            setupOpts.custom_colorcolumn = {
              # this is a freeform module, it's `buftype = int;` for configuring column position
              nix = "110";
              ruby = "120";
              java = "130";
              go = ["90" "130"];
            };
          };
          fastaction.enable = true;
        };

        comments = {
          comment-nvim.enable = true;
        };

        presence = {
          neocord.enable = true;
        };
      };
    };
  };
}
