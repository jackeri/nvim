return {
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

  {
    'Civitasv/cmake-tools.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('cmake-tools').setup {}
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
}
