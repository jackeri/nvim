return {
  -- Filetree
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    enabled = not vim.g.use_netrw,
    config = function()
      -- disable netrw at the very start of your init.lua
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require('nvim-tree').setup {
        sort = {
          sorter = 'case_sensitive',
        },
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = true,
        },
        disable_netrw = true,
        update_focused_file = {
          enable = true,
        },
      }
      vim.keymap.set('n', '<c-p>', function()
        local tree = require 'nvim-tree.api'
        tree.tree.toggle()
      end, { desc = 'Toggle NvimTree' })

      vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('NvimTreeClose', { clear = true }),
        pattern = 'NvimTree_*',
        callback = function()
          local layout = vim.api.nvim_call_function('winlayout', {})
          local window = tonumber(layout[2])
          if type(window) ~= 'number' then
            return
          end
          local type = vim.api.nvim_get_option_value('filetype', { win = window })
          if layout[1] == 'leaf' and type == 'NvimTree' and layout[3] == nil then
            vim.cmd 'confirm quit'
          end
        end,
      })
    end,
  },
}
