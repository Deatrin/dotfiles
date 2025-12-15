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

        nix.enable = true;
        markdown.enable = true;
        bash.enable = true;
        go.enable = true;
        html.enable = true;
        helm.enable = true;
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
          theme = "dracula";
        };
      };

      theme = {
        enable = true;
        name = "dracula";
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
        breadcrumbs = {
          enable = true;
          navbuddy.enable = true;
        };
      };

      # extraPlugins = with pkgs.unstable.vimPlugins; {
      #   claude-code = {
      #     package = claude-code-nvim;
      #     setup = ''
      #         require("claude-code").setup({
      #         -- Terminal window settings
      #         window = {
      #           split_ratio = 0.3,      -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
      #           position = "botright",  -- Position of the window: "botright", "topleft", "vertical", "float", etc.
      #           enter_insert = true,    -- Whether to enter insert mode when opening Claude Code
      #           hide_numbers = true,    -- Hide line numbers in the terminal window
      #           hide_signcolumn = true, -- Hide the sign column in the terminal window

      #           -- Floating window configuration (only applies when position = "float")
      #           float = {
      #             width = "80%",        -- Width: number of columns or percentage string
      #             height = "80%",       -- Height: number of rows or percentage string
      #             row = "center",       -- Row position: number, "center", or percentage string
      #             col = "center",       -- Column position: number, "center", or percentage string
      #             relative = "editor",  -- Relative to: "editor" or "cursor"
      #             border = "rounded",   -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
      #           },
      #         },
      #         -- File refresh settings
      #         refresh = {
      #           enable = true,           -- Enable file change detection
      #           updatetime = 100,        -- updatetime when Claude Code is active (milliseconds)
      #           timer_interval = 1000,   -- How often to check for file changes (milliseconds)
      #           show_notifications = true, -- Show notification when files are reloaded
      #         },
      #         -- Git project settings
      #         git = {
      #           use_git_root = true,     -- Set CWD to git root when opening Claude Code (if in git project)
      #         },
      #         -- Shell-specific settings
      #         shell = {
      #           separator = '&&',        -- Command separator used in shell commands
      #           pushd_cmd = 'pushd',     -- Command to push directory onto stack (e.g., 'pushd' for bash/zsh, 'enter' for nushell)
      #           popd_cmd = 'popd',       -- Command to pop directory from stack (e.g., 'popd' for bash/zsh, 'exit' for nushell)
      #         },
      #         -- Command settings
      #         command = "claude",        -- Command used to launch Claude Code
      #         -- Command variants
      #         command_variants = {
      #           -- Conversation management
      #           continue = "--continue", -- Resume the most recent conversation
      #           resume = "--resume",     -- Display an interactive conversation picker

      #           -- Output options
      #           verbose = "--verbose",   -- Enable verbose logging with full turn-by-turn output
      #         },
      #         -- Keymaps
      #         keymaps = {
      #           toggle = {
      #             normal = "<C-,>",       -- Normal mode keymap for toggling Claude Code, false to disable
      #             terminal = "<C-,>",     -- Terminal mode keymap for toggling Claude Code, false to disable
      #             variants = {
      #               continue = "<leader>cC", -- Normal mode keymap for Claude Code with continue flag
      #               verbose = "<leader>cV",  -- Normal mode keymap for Claude Code with verbose flag
      #             },
      #           },
      #           window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
      #           scrolling = true,         -- Enable scrolling keymaps (<C-f/b>) for page up/down
      #         }
      #       })
      #     '';
      #   };
      # };

      comments = {
        comment-nvim.enable = true;
      };
    };
  };
}
