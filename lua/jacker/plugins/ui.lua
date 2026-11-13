return {
  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      -- setup() populates vim.g.onedark_config, which the lualine onedark theme requires
      require('onedark').setup {}
      require('onedark').load()
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
      tabline = {
        lualine_a = {},
        lualine_b = {
          {
            'filename',
            path = 2,
          },
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      sections = {
        lualine_c = { 'filename' },
        lualine_x = { 'datetime', 'encoding', 'fileformat', 'filetype' },
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    opts = {},
    config = function(_, opts)
      require('which-key').setup(opts)

      -- document existing key chains
      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = 'Harpoon' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>v', group = '[V]im' },
        { '<leader>vr', group = '[V]im [R]eload' },
        { '<leader>u', group = '[U]ndo tree' },
        { '<leader>l', group = '[L]azy' },
        { '<C-n>', group = 'Multicursor select word' },
      }
    end,
  },

  {
    'rcarriga/nvim-notify',
    enabled = true,
    event = 'VeryLazy',
    config = function()
      local notify = require 'notify'
      notify.setup {
        background_colour = 'NotifyBackground',
        fps = 30,
        icons = {
          DEBUG = '',
          ERROR = '',
          INFO = '',
          TRACE = '✎',
          WARN = '',
        },
        level = 2,
        minimum_width = 50,
        render = 'compact',
        stages = 'fade_in_slide_out',
        time_formats = {
          notification = '%T',
          notification_history = '%FT%T',
        },
        timeout = 5000,
        top_down = true,
      }
      vim.notify = notify
    end,
  },

  {
    -- Noice cmdline (experimental)
    'folke/noice.nvim',
    event = 'VeryLazy',
    enabled = false,
    opts = {},
    config = function()
      require('noice').setup {
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      }
    end,
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
  },
}
