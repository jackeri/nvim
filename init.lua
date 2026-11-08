--[[
NOTE: This config has grown well beyond the original kickstart.nvim template.
Most of it now lives under lua/jacker/ so this file stays a short bootstrap:
  lua/jacker/options.lua       - `vim.o`/`vim.opt` settings
  lua/jacker/keymaps.lua       - generic (non-plugin-specific) keymaps
  lua/jacker/autocommands.lua  - generic autocommands
  lua/jacker/netrw.lua         - optional netrw setup (see `vim.g.use_netrw` below)
  lua/jacker/lsp/              - mason, server list, jdtls/vue_ls/ltex setup
  lua/jacker/plugins/*.lua     - one lazy.nvim plugin spec (or group) per file
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Set to true to use netrw instead of nvim-tree as the file explorer.
-- See lua/jacker/netrw.lua and lua/jacker/plugins/nvim-tree.lua
vim.g.use_netrw = false
if vim.g.use_netrw then
  require 'jacker.netrw'
end

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
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

-- NOTE: Here is where your plugins are installed.
--  Every file under lua/jacker/plugins/ returns a lazy.nvim plugin spec (or a
--  list of specs); `import` below discovers and loads all of them.
--  See: https://lazy.folke.io/spec#spec_import
require('lazy').setup({
  { import = 'jacker.plugins' },
}, {})

require 'jacker.options'
require 'jacker.keymaps'
require 'jacker.autocommands'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
