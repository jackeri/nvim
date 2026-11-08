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

      -- Case 1: closing the last "real" buffer/window leaves only the
      -- NvimTree window behind, which then just expands to fill the
      -- screen. Detect that and quit instead of leaving a lone tree.
      vim.api.nvim_create_autocmd('BufEnter', {
        group = vim.api.nvim_create_augroup('NvimTreeClose', { clear = true }),
        nested = true,
        callback = function()
          -- avoid firing while nvim is still starting up (e.g. `nvim .`
          -- briefly having only the tree window open before other buffers
          -- are restored)
          if vim.v.vim_did_enter ~= 1 then
            return
          end
          if #vim.api.nvim_list_wins() == 1 and require('nvim-tree.api').tree.is_tree_buf(0) then
            vim.cmd 'confirm quit'
          end
        end,
      })

      -- Case 2: quitting (`:q`, `:wq`, `:qall`) from the last normal window
      -- while NvimTree is still open only closes the current window,
      -- leaving NvimTree behind instead of exiting. QuitPre fires before
      -- Vim would exit, so close any NvimTree windows first to let the
      -- pending quit actually close Neovim.
      vim.api.nvim_create_autocmd('QuitPre', {
        group = vim.api.nvim_create_augroup('NvimTreeQuit', { clear = true }),
        callback = function()
          local tree_api = require 'nvim-tree.api'
          local tree_wins, floating_wins = {}, {}
          local wins = vim.api.nvim_list_wins()
          for _, w in ipairs(wins) do
            if tree_api.tree.is_tree_buf(vim.api.nvim_win_get_buf(w)) then
              table.insert(tree_wins, w)
            elseif vim.api.nvim_win_get_config(w).relative ~= '' then
              table.insert(floating_wins, w)
            end
          end
          if #wins - #floating_wins - #tree_wins == 1 then
            -- only one non-floating, non-tree window remains: this quit
            -- would otherwise just close the tree, so close it now and
            -- let the quit proceed to actually exit Neovim
            for _, w in ipairs(tree_wins) do
              pcall(vim.api.nvim_win_close, w, true)
            end
          end
        end,
      })
    end,
  },
}
