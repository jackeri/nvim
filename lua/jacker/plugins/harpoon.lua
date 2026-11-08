return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup {}

      require('telescope').load_extension 'harpoon'

      -- basic telescope configuration
      local conf = require('telescope.config').values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require('telescope.pickers')
          .new({}, {
            prompt_title = 'Harpoon',
            finder = require('telescope.finders').new_table {
              results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
          })
          :find()
      end

      vim.keymap.set('n', '<leader>ht', function()
        toggle_telescope(harpoon:list())
      end, { desc = 'Open [h]arpoon [t]elescope window' })

      vim.keymap.set('n', '<leader>hd', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Toggle [H]arpoon menu' })
      vim.keymap.set('n', '<leader>ha', function()
        harpoon:list():add()
      end, { desc = '[A]dd file to [h]arpoon' })
      vim.keymap.set('n', '<leader>hr', function()
        harpoon:list():remove()
      end, { desc = '[R]emove file from [h]arpoon' })
      vim.keymap.set('n', '<Tab>', function()
        harpoon:list():next { ui_nav_wrap = true }
      end, { desc = '[H]arpoon next' })
      vim.keymap.set('n', '<BS>', function()
        harpoon:list():prev { ui_nav_wrap = true }
      end, { desc = '[H]arpoon previous' })
      vim.keymap.set('n', '<leader>h', function()
        local c = vim.fn.getchar() - 48
        if c < 0 or c > 10 then
          return
        end
        harpoon:list():select(c)
      end, { desc = 'Jump to [h]arpoon file' })
    end,
  },
}
