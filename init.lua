--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

UseNetrw = false
if UseNetrw then
  vim.g.netrw_keepdir = 0
  vim.g.netrw_banner = 0
  vim.g.netrw_list_hide = '\\(^\\|\\s\\s\\)\zs\\.\\S\\+'
  vim.g.netrw_localcopydircmd = 'cp -r'
  vim.g.netrw_winsize = 30
  -- vim.keymap.set('n', '<c-p>', ':Vexplore %:p:h<CR>', { desc = 'Toggle NvimTree', silent = true })
  vim.keymap.set('n', '<c-p>', ':Explore %:p:h<CR>', { desc = 'Toggle NvimTree', silent = true })
end

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  { 'tpope/vim-sleuth', event = 'VeryLazy' },

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.

  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      {
        'mason-org/mason-lspconfig.nvim',
        opts = {},
        dependencies = {
          { 'mason-org/mason.nvim', opts = {} },
        },
      },

      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
  },

  {
    'L3MON4D3/LuaSnip',
    -- follow latest release.
    version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = 'make install_jsregexp',
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
      'hrsh7th/cmp-cmdline',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').preview_hunk, { buffer = bufnr, desc = 'Preview git hunk' })

        -- don't override the built-in and fugitive keymaps
        local gs = package.loaded.gitsigns
        vim.keymap.set({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to next hunk' })
        vim.keymap.set({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, buffer = bufnr, desc = 'Jump to previous hunk' })
      end,
    },
  },

  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'onedark'
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
        lualine_c = {
          'filename',
          function()
            return require('nvim-treesitter').statusline()
          end,
        },
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

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build',
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- [[ Configure Telescope ]]
      local telescope = require 'telescope'
      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
        file_ignore_patterns = { 'node_modules', '.git', 'dist', 'build', 'target', 'vendor' },
        path_display = { 'truncate' },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')
      local builtin = require 'telescope.builtin'
      -- See `:help telescope.builtin`
      vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<D-e>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Search [G]it [F]iles' })
      vim.keymap.set('n', '<leader>sf', function()
        builtin.find_files { path_display = { 'truncate' }, shorter_path = true }
      end, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', function()
        builtin.live_grep { debounce = 1000 }
      end, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  {
    'numToStr/Comment.nvim',
    opts = {
      -- add any options here
    },
    lazy = false,
  },

  {
    'rcarriga/nvim-dap-ui',
    event = 'VeryLazy',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      -- [[ Configure DAP ]]
      local dap, dapui = require 'dap', require 'dapui'
      dapui.setup()
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
  },

  {
    'jay-babu/mason-nvim-dap.nvim',
    event = 'VeryLazy',
    dependencies = {
      'williamboman/mason.nvim',
      'mfussenegger/nvim-dap',
    },
    opts = {
      handlers = {},
    },
  },

  { 'mfussenegger/nvim-dap' },

  {
    'Civitasv/cmake-tools.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('cmake-tools').setup {}
    end,
  },

  { 'mg979/vim-visual-multi' },

  {
    url = 'https://codeberg.org/andyg/leap.nvim',
    dependencies = {
      'tpope/vim-repeat',
    },
    config = function()
      -- Leap configiration (use the defaults for now)
      -- NOTE: this is deprecated figure out what to do later
      -- require('leap').add_default_mappings()
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
      vim.keymap.set({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)')
      vim.keymap.set('n', 'gs', '<Plug>(leap-from-window)')
    end,
  },

  { 'norcalli/nvim-colorizer.lua' },

  {
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },

  -- Filetree
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    enabled = not UseNetrw,
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
          if not type(window) == 'number' then
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

  -- LaTex
  {
    'lervag/vimtex',
    init = function()
      if vim.fn.has 'macunix' == 1 then
        vim.g.vimtex_compiler_latexmk = {
          options = {
            '-xelatex',
            '-file-line-error',
            '-synctex=1',
            '-interaction=nonstopmode',
            '-shell-escape',
          },
        }
        vim.g.vimtex_view_method = 'skim'
        vim.g.vimtex_view_skim_sync = 1
        vim.g.vimtex_view_skim_activate = 1
      end
    end,
  },
  { 'smithbm2316/centerpad.nvim' },
  { 'fedepujol/move.nvim' },

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
      -- vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("<CR>")', { expr = true, silent = true })
      vim.keymap.set('i', '<C-J>', function()
        -- vim.fn['copilot#Accept'] '<CR>'
        vim.fn.feedkeys(vim.fn['copilot#Accept'] '<CR>', '')
      end, { silent = true })
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

  -- Hightlight whitespace text
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
  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  require 'jacker.plugins.format',
  require 'jacker.plugins.lint',

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

  -- Noice cmmandline (experimenta)
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    enabled = false,
    opts = {
      -- add any options here
    },
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
          DEBUG = '',
          ERROR = '',
          INFO = '',
          TRACE = '✎',
          WARN = '',
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
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    config = function()
      require('lsp_lines').setup()
      -- Disable default inline diagnostics
      -- Since we are using whynothugo/lsp_lines.nvim
      vim.diagnostic.config {
        virtual_text = false,
      }
    end,
    enabled = false, -- Disable for now.. Maybe just remove this?
  },

  {
    'APZelos/blamer.nvim',
    config = function()
      vim.g.blamer_enabled = 1
    end,
  },

  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})
-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`

vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- vim.fn.sign_define('DapBreakpoint', { text = '🟥', texthl = '', linehl = '', numhl = '' })
-- vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = '', numhl = '' })

vim.keymap.set('n', '<F8>', require('dap').continue, { desc = 'Dap continue' })
vim.keymap.set('n', '<F6>', require('dap').step_over, { desc = 'Dap step over' })
vim.keymap.set('n', '<F5>', require('dap').step_into, { desc = 'Dap step into' })
vim.keymap.set('n', '<F7>', require('dap').step_out, { desc = 'Dap step out' })
vim.keymap.set('n', '<leader>b', require('dap').toggle_breakpoint, { desc = 'Toggle [b]reakpoint' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'

local ts_setup_done = false
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'vue', 'css', 'scss' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
        },
      },
    },
  }
  ts_setup_done = true
  vim.opt.foldmethod = 'expr'
  vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
end, 0)

-- Enable the treesitter folding if supported by the current buffer
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost' }, {
  callback = function()
    if not ts_setup_done then
      return
    end
    if vim.opt.foldexpr == 'nvim_treesitter#foldexpr()' then
      return
    end
    -- Check if the current buffer has a treesitter highlighter support
    if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil then
      vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.wo.foldmethod = 'expr'
      -- vim.schedule(function()
      --   vim.cmd.normal 'zx' -- update folds
      -- end)
    else
      vim.wo.foldmethod = 'manual'
    end
  end,
})

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
  callback = function(event)
    vim.notify('LSP started', vim.log.levels.DEBUG)
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc, mode)
      if desc then
        desc = 'LSP: ' .. desc
      end
      mode = mode or 'n'

      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', function()
      require('telescope.builtin').lsp_references {
        show_line = false,
        include_declaration = false,
        sorting_strategy = 'ascending',
      }
    end, '[G]oto [R]eferences')
    nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
    nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

    -- See `:help K` for why this keymap
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

    -- Lesser used LSP functionality
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
    nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
    nmap('<leader>wl', function()
      vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()), vim.log.levels.INFO)
    end, '[W]orkspace [L]ist Folders')

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(event.buf, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })

    -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
    ---@param client vim.lsp.Client
    ---@param method vim.lsp.protocol.Method
    ---@param bufnr? integer some lsp support methods only in specific files
    ---@return boolean
    local function client_supports_method(client, method, bufnr)
      if vim.fn.has 'nvim-0.11' == 1 then
        return client:supports_method(method, bufnr)
      else
        return client.supports_method(method, { bufnr = bufnr })
      end
    end

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      nmap('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- document existing key chains
require('which-key').add {
  { '<leader>c', group = '[C]ode' },
  { '<leader>d', group = '[D]ocument' },
  { '<leader>g', group = '[G]it' },
  -- {'<leader>h', group = 'More git'},
  { '<leader>h', group = 'Harpoon' },
  { '<leader>r', group = '[R]ename' },
  { '<leader>s', group = '[S]earch' },
  { '<leader>w', group = '[W]orkspace' },
  { '<leader>v', group = '[V]im' },
  { '<leader>vr', group = '[V]im [R]reload' },
  { '<leader>u', group = '[U]ndo tree' },
  { '<leader>l', group = '[L]azy' },
  { 'C-n', group = 'Multicursor select word' },
}

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup {
  ui = {
    icons = {
      package_installed = '✓',
      package_pending = '➜',
      package_uninstalled = '✗',
    },
  },
}

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  clangd = {
    cmd = { 'clangd', '--background-index', '--offset-encoding=utf-16' },
  },
  -- gopls = {},
  -- pyright = {},
  rust_analyzer = {},
  -- ts_ls = {},
  html = { filetypes = { 'html', 'twig', 'hbs' } },

  lua_ls = {
    -- Lua = {
    --   workspace = { checkThirdParty = false },
    --   telemetry = { enable = false },
    -- },
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
        -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },

  lemminx = { filetypes = { 'xml' } },
  intelephense = {},
  zls = {},
  vue_ls = {},
  vtsls = {},
}

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  'stylua', -- Used to format Lua code
})
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

-- LSP servers and clients are able to communicate to each other what features they support.
--  By default, Neovim doesn't support everything that is in the LSP specification.
--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = {},
  automatic_installation = false,
  handlers = {
    function(server_name)
      local server = servers[server_name] or {}
      -- This handles overriding only values explicitly passed
      -- by the server configuration above. Useful when disabling
      -- certain features of an LSP (for example, turning off formatting for ts_ls)
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      vim.lsp.config(server_name, server)
      vim.lsp.enable(server_name)
    end,
  },
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()

local function setup_snippets()
  local s = luasnip.snippet
  local t = luasnip.text_node
  local java_uid = s('uid', t 'private static final long serialVersionUID = 1;')
  luasnip.add_snippets('Java', { java_uid })
end
setup_snippets()

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() and cmp.get_selected_index() ~= nil then
        cmp.confirm {
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
        -- vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      elseif vim.b._copilot_suggestion ~= nil then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes(vim.fn['copilot#Accept'](), true, true, true), '')
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
  },
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' },
      },
    },
  }),
})

-- reload this vim configuration without the need to restart the whole editor
local function reload_vim_config()
  for name, _ in pairs(package.loaded) do
    if name:match '^user' and not name:match 'nvim-tree' then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  vim.notify('Nvim configuration reloaded!', vim.log.levels.INFO)
end
vim.keymap.set('n', '<leader>vrc', reload_vim_config, { desc = '[V]im [R]reload [C]onfig' })

-- enable relative line nubmers and center the cursor location
local g = vim.g -- global options
local wo = vim.wo -- window options
local bo = vim.bo -- buffer options
local set = vim.opt -- set options
local notify = require 'notify'

local TAB_WIDTH = 2 -- I like 4 chars as a tab, setup as you wish
wo.relativenumber = true -- relative line numbers
set.scrolloff = 10 -- scrolling offset from top/bottom
set.cursorline = true -- hightlight the current cursor line
set.expandtab = false -- use the normal tab character and not the expanded tab aka spaces
set.tabstop = TAB_WIDTH
set.softtabstop = TAB_WIDTH
set.shiftwidth = TAB_WIDTH

-- Restore cursor position
vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
  pattern = '*',
  callback = function()
    -- do not restore cursor when doing a git commit
    -- the GIT_AUTHOR_EMAIL env variable should only be set when doing a git command
    if vim.env.GIT_AUTHOR_EMAIL == nil then
      vim.api.nvim_exec2('silent! normal! g`"zv', { output = false })
    end
  end,
})

if vim.lsp.inlay_hint then
  vim.keymap.set('n', '<leader>uh', function()
    -- First is the buffer which to use, it could be fetched with: nvim.api.nvim_get_current_buf(). 0 value uses current buffer
    -- the second param is a bool if to enable or disable the hints (nil will toggle the hints)
    vim.lsp.inlane_hint(0, nil)
  end, { desc = 'Toggle f[u]nction inlay [H]ints' })
end

local function toggle_listchars()
  -- vim.opt.listchars = { eol = '¬', tab = '>·', trail = '~', extends = '>', precedes = '<', space = '␣' }
  vim.opt.listchars = { eol = '↵', tab = '⇤–⇥', trail = '·', extends = '⇢', precedes = '⇠', space = '·' }
  vim.cmd 'set list!'
  -- vim.opt.list = not vim.opt.list
end
vim.keymap.set('n', '<leader>vl', toggle_listchars, { desc = 'Toggle [v]im [l]istchars' })

-- Enable colorizer for all files and enable the rbg and hex parsing
require('colorizer').setup({
  '*',
}, { rgb_fn = true, RRGGBBAA = true })

vim.keymap.set('n', '<leader>cn', function()
  require('todo-comments').jump_next()
end, { desc = '[N]ext todo [c]omment' })

vim.keymap.set('n', '<leader>cp', function()
  require('todo-comments').jump_prev()
end, { desc = '[P]revious todo [c]omment' })

vim.keymap.set('n', '<leader>st', function()
  vim.cmd ':TodoTelescope'
end, { desc = '[S]earch [T]odos' })

vim.keymap.set('n', '*', '*zz', { desc = 'Search and center screen' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Move up and center screen' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Mode down and center screen' })

-- Use groovy as the default Jenkinsfile syntax
-- vim.cmd('autocmd BufNewFile,BufRead Jenkinsfile set syntax=groovy')
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { 'Jenkinsfile' },
  callback = function(_)
    notify('Jenkinsfile detected', vim.log.levels.INFO)
    vim.o.syntax = 'groovy'
  end,
  -- command = 'set syntax=groovy'
})

-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = { '<filetype>' },
--   callback = function()
--     vim.treesitter.start()
--     if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil then
--       vim.wo.foldmethod = 'expr'
--       vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
--     else
--       vim.wo.foldmethod = 'manual'
--     end
--   end,
-- })

vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- Escape terminal mode with Contro-space
vim.keymap.set('t', '<C-space>', '<C-\\><C-n>', { silent = true })

require('telescope').load_extension 'harpoon'
local harpoon = require 'harpoon'
harpoon:setup {}

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

vim.api.nvim_create_user_command('ToTabs', function(props)
  local ts
  if props.args == nil or props.args == '' then
    ts = 4
  else
    ts = tonumber(props.args)
  end
  vim.cmd('set ts=' .. ts .. [[

    set noet
    %retab!
    %s/\s\+$//e
  ]])
end, { desc = 'Change current buffers indentation to tabs (defaults to 4 spaces)', nargs = '?' })

-- Only use soft-wrapping
vim.opt.wrap = true
vim.opt.wrapmargin = 0
vim.opt.textwidth = 0
vim.opt.linebreak = true

local mason_registry = require 'mason-registry'

local function find_format_file(cwd, file)
  local cfgPath = cwd .. '/' .. file
  if not vim.loop.fs_stat(cfgPath) then
    cfgPath = cwd .. '/style/' .. file
    if not vim.loop.fs_stat(cfgPath) then
      cfgPath = nil
    end
  end
  return cfgPath
end

-- Setup the LSP servers for Java
local function setup_jdtls(registry)
  if not registry.is_installed 'jdtls' then
    return
  end
  local settingsTable = nil

  -- Try to find a local style.xml file for JDTLS formatter
  local cwd = vim.fn.getcwd()
  local cfgPath = find_format_file(cwd, 'style.xml')
  local importOrderFile = find_format_file(cwd, 'style.importorder')

  if cfgPath then
    settingsTable = { url = cfgPath }
  else
    -- Check for Eclipse style configuration and set it up for JDTLS
    local eclipseStyleConfig = os.getenv 'ECLIPSE_STYLE_CONFIG'
    local eclipseStyleProfile = os.getenv 'ECLIPSE_STYLE_PROFILE'
    if eclipseStyleConfig and string.len(eclipseStyleConfig) > 0 and vim.loop.fs_stat(eclipseStyleConfig) then
      settingsTable = {
        url = eclipseStyleConfig,
        profile = eclipseStyleProfile,
      }
    end
  end

  if not settingsTable then
    return
  end

  local function parse_jdk_version(path)
    local jdk_rel = vim.fn.glob(path .. '/release')
    if vim.loop.fs_stat(jdk_rel) then
      local text = vim.fn.readfile(jdk_rel)
      for _, line in ipairs(text) do
        if line:match 'JAVA_VERSION' then
          local version_ok, jdk_version = pcall(tonumber, line:match '([0-9]+)%.?')
          if version_ok and type(jdk_version) == 'number' then
            return jdk_version
          end
        end
      end
    end
    return nil
  end

  local java_paths = {}

  if vim.fn.has 'macunix' == 1 then
    local vms = vim.fn.expand '/Library/Java/JavaVirtualMachines/*/Contents/Home'
    local highest_jvm = -1
    for jdk in vms:gmatch '[^\r\n]+' do
      local jdk_version = parse_jdk_version(jdk)

      if jdk_version then
        if jdk_version > highest_jvm then
          highest_jvm = jdk_version
        end
        table.insert(java_paths, {
          name = 'Java-' .. jdk_version,
          path = jdk,
        })
      end
    end

    for _, jdk in ipairs(java_paths) do
      if jdk.name == 'Java-' .. highest_jvm then
        jdk.default = true
      end
    end
  else
    local java_home = os.getenv 'JAVA_HOME'
    if java_home and string.len(java_home) > 0 then
      local java_home_path = vim.fn.expand(java_home)
      if vim.loop.fs_stat(java_home_path) then
        table.insert(java_paths.runtimes, {
          path = java_home_path,
          name = 'Java',
          default = true,
        })
      end
    end
  end

  -- Check if the JAVA_HOME is set and if it points to a valid JDK
  -- If not, set it to the highest version found
  -- This is a workaround for the JDTLS not being able to find the JDK
  local function check_and_set_jvm()
    local java_home = os.getenv 'JAVA_HOME'
    local java_version = nil
    if java_home and string.len(java_home) > 0 then
      java_version = parse_jdk_version(java_home)
    end

    -- JDTLS requires Java 21 or higher
    if java_version and java_version > 20 then
      return
    end

    for _, jdk in ipairs(java_paths) do
      local version_ok, jdk_version = pcall(tonumber, jdk.path:match '([0-9]+)%.?')
      if version_ok and type(jdk_version) == 'number' then
        if java_version == nil or jdk_version > java_version then
          java_version = jdk_version
          vim.uv.os_setenv('JAVA_HOME', jdk.path)
        end
      end
    end

    if java_version == nil or java_version < 21 then
      notify('No valid JDK(version >= 21) found, please set JAVA_HOME', vim.log.levels.ERROR)
      return
    else
      -- vim.notify('Using JDK ' .. java_version .. ' from ' .. vim.env.JAVA_HOME, vim.log.levels.INFO)
    end
  end

  check_and_set_jvm()

  local importOrderTable = {
    'java',
    'jakarta',
    'javax',
    'com',
    'org',
  }
  if importOrderFile then
    local file = io.open(importOrderFile, 'r')
    local order = {}
    if file then
      for line in file:lines() do
        if line:sub(1, 1) == '#' then
          goto continue
        end
        local offset = line:find '='
        if not offset then
          goto continue
        end
        local key = line:sub(offset + 1):gsub('%s+', '')
        table.insert(order, key)
        ::continue::
      end
      file:close()
      importOrderTable = order
    end
  end

  local home = os.getenv 'HOME'
  local root_dir = vim.fs.dirname(vim.fs.find({ 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }, { upward = true })[1])
  local workspace_folder = home .. '/.local/share/eclipse/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

  vim.lsp.config('jdtls', {
    capabilities = capabilities,

    cmd = {
      vim.fn.expand '$MASON/packages' .. '/jdtls/bin/jdtls',
      '-data',
      workspace_folder,
      '--jvm-arg=-javaagent:' .. vim.fn.expand '$MASON/packages' .. '/jdtls/lombok.jar',
      '--jvm-arg=-Xmx1G',
      '--jvm-arg=-XX:+UseG1GC',
      '--jvm-arg=-XX:+UseStringDeduplication',
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
    },

    root_markers = { 'mvnw', 'gradlew', '.git', 'pom.xml', 'build.gradle' },

    -- ... all your other stuff
    settings = {
      java = {
        import = {
          gradle = {
            enabled = false,
          },
          maven = {
            enabled = false,
          },
        },
        format = {
          settings = settingsTable,
        },
        importOrder = importOrderTable,
        signatureHelp = { enabled = true },
        contentProvider = { preferred = 'fernflower' }, -- Use fernflower to decompile library code
        sources = {
          organizeImports = {
            starThreshold = 4,
            staticStarThreshold = 4,
          },
        },
        -- Specify any completion options
        completion = {
          useWildcard = true,
          wildcardTrigger = 4,
          favoriteStaticMembers = {
            'org.hamcrest.MatcherAssert.assertThat',
            'org.hamcrest.Matchers.*',
            'org.hamcrest.CoreMatchers.*',
            'org.junit.jupiter.api.Assertions.*',
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
            'org.mockito.Mockito.*',
          },
          filteredTypes = {
            'com.sun.*',
            'io.micrometer.shaded.*',
            'java.awt.*',
            'jdk.*',
            'sun.*',
          },
        },
        -- How code generation should act
        codeGeneration = {
          toString = {
            template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
          },
          hashCodeEquals = {
            useJava7Objects = true,
          },
          useBlocks = true,
        },
        eclipse = {
          downloadSources = true,
          -- jdtls = {
          --   vmargs = '-javaagent:/path/to/lombok.jar',
          -- },
        },
        maven = {
          downloadSources = true,
        },
        implementationsCodeLens = {
          enabled = true,
        },
        referencesCodeLens = {
          enabled = true,
        },
        -- configuration = {
        --   runtimes = java_paths,
        -- },
      },
    },
  })
end

setup_jdtls(mason_registry)

local function setup_vue_ls(registry)
  if not registry.is_installed 'vue-language-server' then
    vim.notify('Vue language server not installed', vim.log.levels.ERROR)
    return
  end

  if not registry.is_installed 'vtsls' then
    vim.notify('Vtsls language server not installed', vim.log.levels.ERROR)
    return
  end

  local vue_language_server_path = vim.fn.expand '$MASON/packages' .. '/vue-language-server' .. '/node_modules/@vue/language-server'

  local vue_plugin = {
    name = '@vue/typescript-plugin',
    location = vue_language_server_path,
    languages = { 'vue' },
    configNamespace = 'typescript',
  }

  local vtsls_config = {
    settings = {
      vtsls = {
        tsserver = {
          globalPlugins = {
            vue_plugin,
          },
        },
      },
    },
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
  }

  local vue_ls_config = {
    on_init = function(client)
      client.handlers['tsserver/request'] = function(_, result, context)
        local clients = vim.lsp.get_clients { bufnr = context.bufnr, name = 'vtsls' }
        if #clients == 0 then
          vim.notify('Could not find `vtsls` lsp client, `vue_ls` would not work without it.', vim.log.levels.ERROR)
          return
        end
        local ts_client = clients[1]

        local param = unpack(result)
        local id, command, payload = unpack(param)
        ts_client:exec_cmd({
          title = 'vue_request_forward', -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
          command = 'typescript.tsserverRequest',
          arguments = {
            command,
            payload,
          },
        }, { bufnr = context.bufnr }, function(_, r)
          local response = r and r.body
          -- TODO: handle error or response nil here, e.g. logging
          -- NOTE: Do NOT return if there's an error or no response, just return nil back to the vue_ls to prevent memory leak
          local response_data = { { id, response } }

          ---@diagnostic disable-next-line: param-type-mismatch
          client:notify('tsserver/response', response_data)
        end)
      end
    end,
  }
  -- nvim 0.11 or above
  vim.lsp.config('vtsls', vtsls_config)
  vim.lsp.config('vue_ls', vue_ls_config)
  vim.lsp.enable { 'vtsls', 'vue_ls' }
end

setup_vue_ls(mason_registry)

-- Setup the LTeX language server if it's installed
if mason_registry.is_installed 'ltex' then
  vim.lsp.config('ltex', {
    filetypes = { 'markdown', 'text', 'tex', 'bib' },
    settings = {
      ltex = {
        languageToolHttpServerUri = 'https://api.languagetoolplus.com',
        languageToolOrg = {
          username = os.getenv 'LATOOL_EMAIL',
          apiKey = os.getenv 'LATOOL_TOKEN',
        },
      },
    },
  })
  vim.lsp.enable 'ltex'
end

vim.keymap.set('n', '<leader>tc', function()
  require('centerpad').toggle { leftpad = 30, rightpad = 30 }
end, { silent = true, noremap = true, desc = '[T]oggle [C]enterpad' })
-- vim.keymap.set('n', '<leader>tc', '<cmd>Centerpad<cr>', { silent = true, noremap = true, desc = '[T]oggle [C]enterpad' })

-- local opts = { noremap = true, silent = true }
-- vim.keymap.set('n', '<S-j>', ':m .+1<CR>==', opts)
-- vim.keymap.set('n', '<S-k>', ':m .-2<CR>==', opts)

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

vim.keymap.set('n', '<leader><BS>', ':bd<CR>', { desc = 'Close buffer', silent = true, noremap = true })

vim.filetype.add {
  extension = {
    vert = 'glsl',
    frag = 'glsl',
    geom = 'glsl',
    tesc = 'glsl',
    tese = 'glsl',
    comp = 'glsl',
  },
  pattern = {
    ['.*/.gitconfig-*'] = 'gitconfig',
  },
}

local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
parser_config.blade = {
  install_info = {
    url = 'https://github.com/EmranMR/tree-sitter-blade',
    files = { 'src/parser.c' },
    branch = 'main',
  },
  filetype = 'blade',
}
vim.filetype.add {
  pattern = {
    ['.*%.blade%.php'] = 'blade',
  },
}

-- Copy file path to clipboard
vim.keymap.set('n', '<leader>fr', ':let @+ = expand("%")<CR>', { desc = 'Copy [f]ile [r]elative path to clipboard', noremap = true, silent = true })
vim.keymap.set('n', '<leader>ff', ':let @+ = expand("%:p")<CR>', { desc = 'Copy [f]ile [f]ull path to clipboard', noremap = true, silent = true })
vim.keymap.set('n', '<leader>fn', ':let @+ = expand("%:t")<CR>', { desc = 'Copy [f]ile file[n]ame to clipboard', noremap = true, silent = true })

-- vim.ui_attach(vim.api.nvim_create_namespace 'redirect messages', { ext_messages = true }, function(event, ...)
--   if event == 'msg_show' then
--     local level = vim.log.levels.INFO
--     local kind, content = ...
--     if string.find(kind, 'err') then
--       level = vim.log.levels.ERROR
--     end
--     vim.notify(content, level, { title = 'Message' })
--   end
-- end)

local function setup_close_unused_buffers()
  local id = vim.api.nvim_create_augroup('startup', {
    clear = false,
  })

  local persistbuffer = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    vim.fn.setbufvar(bufnr, 'bufpersist', 1)
  end

  vim.api.nvim_create_autocmd({ 'BufRead' }, {
    group = id,
    pattern = { '*' },
    callback = function()
      vim.api.nvim_create_autocmd({ 'InsertEnter', 'BufModifiedSet' }, {
        buffer = 0,
        once = true,
        callback = function()
          persistbuffer()
        end,
      })
    end,
  })

  vim.keymap.set('n', '<Leader>cub', function()
    local curbufnr = vim.api.nvim_get_current_buf()
    local buflist = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(buflist) do
      if vim.bo[bufnr].buflisted and bufnr ~= curbufnr and (vim.fn.getbufvar(bufnr, 'bufpersist') ~= 1) then
        vim.cmd('bd ' .. tostring(bufnr))
      end
    end
  end, { silent = true, desc = '[C]close [u]nused [b]uffers' })
end

setup_close_unused_buffers()

if vim.g.neovide then
  -- https://neovide.dev/configuration.html
  -- NOTE: This is a workaround for the issue with macOS where the working directory is `/` at startup
  local cwd = vim.fn.getcwd()
  if vim.fn.has 'macunix' and cwd == '/' then
    -- cwd = vim.fn.expand '%:p:h'
    -- vim.api.nvim_command 'set autochdir'
    -- vim.api.nvim_command "cd ~/programming"
    local default_path = vim.fn.expand '~/programming'
    notify('Setting default directory to ' .. default_path, vim.log.levels.INFO)
    vim.api.nvim_set_current_dir(default_path)
  end
  vim.g.neovide_scale_factor = 1.1
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
