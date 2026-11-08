return {
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
      { 'saghen/blink.cmp', branch = 'v1' },
    },
    -- Server configuration, mason setup and LSP keymaps live in lua/jacker/lsp/
    config = function()
      require('jacker.lsp').setup()
    end,
  },
}
