return {
  'nosduco/remote-sshfs.nvim',
  config = function()
    require('remote-sshfs').setup {}
    vim.keymap.set('n', '<leader>rc', function()
      require('remote-sshfs.api').connect()
    end, { desc = '[C]onnect to remote server' })
    vim.keymap.set('n', '<leader>rd', function()
      require('remote-sshfs.api').disconnect()
    end, { desc = '[D]isconnect from remote server' })
    vim.keymap.set('n', '<leader>re', function()
      require('remote-sshfs.api').edit()
    end, { desc = '[E]dit connection' })
  end,
}
