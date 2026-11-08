return {
  -- Copilot setup
  {
    'github/copilot.vim',
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_filetypes = {
        ['*'] = false,
        ['javascript'] = true,
        ['typescript'] = true,
        ['vue'] = true,
        ['lua'] = true,
        ['rust'] = true,
        ['c'] = true,
        ['c#'] = true,
        ['c++'] = true,
        ['go'] = true,
        ['python'] = true,
      }
      vim.keymap.set('i', '<C-J>', function()
        vim.fn.feedkeys(vim.fn['copilot#Accept'] '<CR>', '')
      end, { silent = true })
      vim.keymap.set('i', '<C-L>', '<Plug>(copilot-next)')
      vim.keymap.set('i', '<C-K>', '<Plug>(copilot-previous)')
    end,
    enabled = function()
      -- Only enable copilot if node is version 18 or greater
      local handle = assert(io.popen('node --version', 'r'))
      local output = assert(handle:read '*a')
      handle:close()
      output = string.gsub(string.gsub(string.gsub(output, '^%s+', ''), '%s+$', ''), '[\n\r]+', ' ')
      local major = tonumber(string.sub(output, 2, 3))
      return major >= 18
    end,
  },

  -- ChatGPT
  {
    'jackMort/ChatGPT.nvim',
    event = 'VeryLazy',
    config = function()
      require('chatgpt').setup()
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'folke/trouble.nvim',
      'nvim-telescope/telescope.nvim',
    },
    enabled = false,
  },
}
