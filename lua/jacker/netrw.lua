-- Optional netrw configuration, used only when `vim.g.use_netrw` is enabled
-- (see init.lua). When netrw is used as the file explorer instead of
-- nvim-tree, this sets it up for a nicer experience.

vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = '\\(^\\|\\s\\s\\)\\zs\\.\\S\\+'
vim.g.netrw_localcopydircmd = 'cp -r'
vim.g.netrw_winsize = 30
vim.keymap.set('n', '<c-p>', ':Explore %:p:h<CR>', { desc = 'Toggle NvimTree', silent = true })
