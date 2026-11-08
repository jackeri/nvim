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

-- enable relative line numbers and center the cursor location
local TAB_WIDTH = 2 -- I like 4 chars as a tab, setup as you wish
vim.wo.relativenumber = true -- relative line numbers
vim.opt.scrolloff = 10 -- scrolling offset from top/bottom
vim.opt.cursorline = true -- hightlight the current cursor line
vim.opt.expandtab = false -- use the normal tab character and not the expanded tab aka spaces
vim.opt.tabstop = TAB_WIDTH
vim.opt.softtabstop = TAB_WIDTH
vim.opt.shiftwidth = TAB_WIDTH

vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- Only use soft-wrapping
vim.opt.wrap = true
vim.opt.wrapmargin = 0
vim.opt.textwidth = 0
vim.opt.linebreak = true
