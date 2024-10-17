-- File: lua/custom/plugins/trouble.lua

return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  config = function()
    vim.keymap.set('n', '<leader>td', function()
      require('trouble').toggle()
    end, { desc = '[D]iagnostics / Trouble window' })
    vim.keymap.set('n', '<leader>tw', function()
      require('trouble').toggle 'workspace_diagnostics'
    end, { desc = '[W]orkspace diagnostics' })
    vim.keymap.set('n', '<leader>tf', function()
      require('trouble').toggle 'document_diagnostics'
    end, { desc = '[F]ile diagnostics' })
    vim.keymap.set('n', '<leader>tq', function()
      require('trouble').toggle 'quickfix'
    end, { desc = '[Q]uickfix list' })
    vim.keymap.set('n', '<leader>tl', function()
      require('trouble').toggle 'loclist'
    end, { desc = '[L]ocal list' })
  end,
}
