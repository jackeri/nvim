-- [[ Basic Keymaps ]]
-- Generic keymaps that aren't tied to configuring a specific plugin.
-- See `:help vim.keymap.set()`

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- reload this vim configuration without the need to restart the whole editor
local function reload_vim_config()
  for name, _ in pairs(package.loaded) do
    if name:match '^jacker' and not name:match 'nvim%-tree' then
      package.loaded[name] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  vim.notify('Nvim configuration reloaded!', vim.log.levels.INFO)
end
vim.keymap.set('n', '<leader>vrc', reload_vim_config, { desc = '[V]im [R]eload [C]onfig' })

local function toggle_listchars()
  -- vim.opt.listchars = { eol = '¬', tab = '>·', trail = '~', extends = '>', precedes = '<', space = '␣' }
  vim.opt.listchars = { eol = '↵', tab = '⇤–⇥', trail = '·', extends = '⇢', precedes = '⇠', space = '·' }
  vim.cmd 'set list!'
end
vim.keymap.set('n', '<leader>vl', toggle_listchars, { desc = 'Toggle [v]im [l]istchars' })

vim.keymap.set('n', '*', '*zz', { desc = 'Search and center screen' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Move up and center screen' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Mode down and center screen' })

-- Escape terminal mode with Control-space
vim.keymap.set('t', '<C-space>', '<C-\\><C-n>', { silent = true })

vim.keymap.set('n', '<leader><BS>', ':bd<CR>', { desc = 'Close buffer', silent = true, noremap = true })

-- Copy file path to clipboard
vim.keymap.set('n', '<leader>fr', ':let @+ = expand("%")<CR>', { desc = 'Copy [f]ile [r]elative path to clipboard', noremap = true, silent = true })
vim.keymap.set('n', '<leader>ff', ':let @+ = expand("%:p")<CR>', { desc = 'Copy [f]ile [f]ull path to clipboard', noremap = true, silent = true })
vim.keymap.set('n', '<leader>fn', ':let @+ = expand("%:t")<CR>', { desc = 'Copy [f]ile file[n]ame to clipboard', noremap = true, silent = true })

if vim.lsp.inlay_hint then
  vim.keymap.set('n', '<leader>uh', function()
    -- First is the buffer which to use, it could be fetched with: nvim.api.nvim_get_current_buf(). 0 value uses current buffer
    -- the second param is a bool if to enable or disable the hints (nil will toggle the hints)
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 })
  end, { desc = 'Toggle f[u]nction inlay [H]ints' })
end

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
