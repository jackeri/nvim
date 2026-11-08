-- [[ Configure LSP ]]
-- Mason, mason-lspconfig, server configuration and LSP keymaps.

local M = {}

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

-- This function gets run when an LSP connects to a particular buffer.
local function on_attach(event)
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
end

-- Setup the LTeX language server if it's installed
local function setup_ltex(mason_registry)
  if not mason_registry.is_installed 'ltex' then
    return
  end

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

function M.setup()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('config-lsp-attach', { clear = true }),
    callback = on_attach,
  })

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

  local mason_registry = require 'mason-registry'
  require('jacker.lsp.jdtls').setup(mason_registry, capabilities)
  require('jacker.lsp.vue').setup(mason_registry)
  setup_ltex(mason_registry)
end

return M
