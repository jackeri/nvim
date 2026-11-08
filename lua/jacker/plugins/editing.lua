return {
  -- Detect tabstop and shiftwidth automatically
  { 'tpope/vim-sleuth', event = 'VeryLazy' },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {}, lazy = false },

  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  { 'mg979/vim-visual-multi' },

  {
    url = 'https://codeberg.org/andyg/leap.nvim',
    dependencies = {
      'tpope/vim-repeat',
    },
    config = function()
      -- Leap configuration (use the defaults for now)
      -- NOTE: this is deprecated figure out what to do later
      -- require('leap').add_default_mappings()
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
      vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)')
      vim.keymap.set('n', 'gs', '<Plug>(leap-from-window)')
    end,
  },

  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      -- Enable colorizer for all files and enable the rbg and hex parsing
      require('colorizer').setup({ '*' }, { rgb_fn = true, RRGGBBAA = true })
    end,
  },

  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
    keys = {
      {
        '<leader>cn',
        function()
          require('todo-comments').jump_next()
        end,
        desc = '[N]ext todo [c]omment',
      },
      {
        '<leader>cp',
        function()
          require('todo-comments').jump_prev()
        end,
        desc = '[P]revious todo [c]omment',
      },
      { '<leader>st', '<cmd>TodoTelescope<cr>', desc = '[S]earch [T]odos' },
    },
  },

  {
    'ntpeters/vim-better-whitespace',
    setup = function()
      vim.g.better_whitespace_enabled = 1
      vim.g.strip_whitespace_on_save = 0
    end,
  },

  {
    'jiaoshijie/undotree',
    dependencies = 'nvim-lua/plenary.nvim',
    config = true,
    keys = { -- load the plugin only when using it's keybinding:
      { '<leader>u', "<cmd>lua require('undotree').toggle()<cr>" },
    },
  },

  {
    'smithbm2316/centerpad.nvim',
    keys = {
      {
        '<leader>tc',
        function()
          require('centerpad').toggle { leftpad = 30, rightpad = 30 }
        end,
        silent = true,
        noremap = true,
        desc = '[T]oggle [C]enterpad',
      },
    },
  },

  {
    'fedepujol/move.nvim',
    event = 'VeryLazy',
    config = function()
      require('move').setup {
        line = {
          enable = true, -- Enables line movement
          indent = true, -- Toggles indentation
        },
        block = {
          enable = true, -- Enables block movement
          indent = true, -- Toggles indentation
        },
        word = {
          enable = true, -- Enables word movement
        },
        char = {
          enable = false, -- Enables char movement
        },
      }

      local opts = { noremap = true, silent = true }
      -- Normal-mode commands
      vim.keymap.set('n', '<S-Down>', ':MoveLine(1)<CR>', opts)
      vim.keymap.set('n', '<S-Up>', ':MoveLine(-1)<CR>', opts)
      vim.keymap.set('n', '<S-Left>', ':MoveHChar(-1)<CR>', opts)
      vim.keymap.set('n', '<S-Right>', ':MoveHChar(1)<CR>', opts)
      vim.keymap.set('n', '<leader>wf', ':MoveWord(1)<CR>', opts)
      vim.keymap.set('n', '<leader>wb', ':MoveWord(-1)<CR>', opts)

      -- Visual-mode commands
      vim.keymap.set('v', '<S-Down>', ':MoveBlock(1)<CR>', opts)
      vim.keymap.set('v', '<S-Up>', ':MoveBlock(-1)<CR>', opts)
      vim.keymap.set('v', '<S-Left>', ':MoveHBlock(-1)<CR>', opts)
      vim.keymap.set('v', '<S-Right>', ':MoveHBlock(1)<CR>', opts)
    end,
  },
}
