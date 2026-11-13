return {
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    dependencies = {
      -- must track `main` to match nvim-treesitter's `main` branch (`master` requires the removed `nvim-treesitter.configs`)
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    build = ':TSUpdate',
    config = function()
      -- ensure basic parser are installed
      local parsers = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'vue', 'css', 'scss' }
      require('nvim-treesitter').install(parsers)

      ---@param buf integer
      ---@param language string
      local function treesitter_try_attach(buf, language)
        -- check if parser exists and load it
        if not vim.treesitter.language.add(language) then
          return
        end
        -- enables syntax highlighting and other treesitter features
        vim.treesitter.start(buf, language)

        -- enables treesitter based folds
        -- for more info on folds see `:help folds`
        -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- vim.wo.foldmethod = 'expr'

        vim.defer_fn(function()
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo.foldmethod = 'expr'
          -- vim.cmd 'normal zx' -- recalculate folds
        end, 1000)

        -- enables treesitter based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      local available_parsers = require('nvim-treesitter').get_available()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end

          local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

          if vim.tbl_contains(installed_parsers, language) then
            -- enable the parser if it is installed
            treesitter_try_attach(buf, language)
          elseif vim.tbl_contains(available_parsers, language) then
            -- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
            require('nvim-treesitter').install(language):await(function()
              treesitter_try_attach(buf, language)
            end)
          else
            -- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
            treesitter_try_attach(buf, language)
          end
        end,
      })

      -- nvim-treesitter-textobjects (main branch): setup only takes options, keymaps are defined manually
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        },
        move = {
          set_jumps = true, -- whether to set jumps in the jumplist
        },
      }

      local ts_select = require 'nvim-treesitter-textobjects.select'
      for lhs, query in pairs {
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      } do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          ts_select.select_textobject(query, 'textobjects')
        end, { desc = 'Select ' .. query })
      end

      local ts_move = require 'nvim-treesitter-textobjects.move'
      for fn, maps in pairs {
        goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
        goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
        goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
        goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
      } do
        for lhs, query in pairs(maps) do
          vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            ts_move[fn](query, 'textobjects')
          end, { desc = fn .. ' ' .. query })
        end
      end

      local ts_swap = require 'nvim-treesitter-textobjects.swap'
      vim.keymap.set('n', '<leader>a', function()
        ts_swap.swap_next '@parameter.inner'
      end, { desc = 'Swap next parameter' })
      vim.keymap.set('n', '<leader>A', function()
        ts_swap.swap_previous '@parameter.inner'
      end, { desc = 'Swap previous parameter' })
    end,
  },

  {
    'MeanderingProgrammer/treesitter-modules.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<M-space>',
        },
      },
    },
  },
}
