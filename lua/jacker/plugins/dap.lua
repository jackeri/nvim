return {
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
      'mason-org/mason.nvim',
      'mfussenegger/nvim-dap',
    },
    opts = {
      handlers = {},
    },
  },

  {
    'mfussenegger/nvim-dap',
    keys = {
      {
        '<F8>',
        function()
          require('dap').continue()
        end,
        desc = 'Dap continue',
      },
      {
        '<F6>',
        function()
          require('dap').step_over()
        end,
        desc = 'Dap step over',
      },
      {
        '<F5>',
        function()
          require('dap').step_into()
        end,
        desc = 'Dap step into',
      },
      {
        '<F7>',
        function()
          require('dap').step_out()
        end,
        desc = 'Dap step out',
      },
      {
        '<leader>b',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Toggle [b]reakpoint',
      },
    },
    config = function()
      vim.fn.sign_define('DapBreakpoint', { text = '🟥', texthl = '', linehl = '', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = '', numhl = '' })
    end,
  },
}
