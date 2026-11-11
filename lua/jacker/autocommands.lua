-- [[ General autocommands ]]
-- Autocommands that aren't tied to configuring a specific plugin.

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

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

vim.filetype.add {
  extension = {
    vert = 'glsl',
    frag = 'glsl',
    geom = 'glsl',
    tesc = 'glsl',
    tese = 'glsl',
    comp = 'glsl',
  },
  filename = {
    Jenkinsfile = 'groovy',
  },
  pattern = {
    ['.*/.gitconfig-*'] = 'gitconfig',
  },
}

-- Close unlisted/unmodified buffers that were never actually used
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
    local default_path = vim.fn.expand '~/programming'
    vim.notify('Setting default directory to ' .. default_path, vim.log.levels.INFO)
    vim.api.nvim_set_current_dir(default_path)
    vim.g.neovide_input_macos_option_key_is_meta = 'only-left'
  end
  vim.g.neovide_scale_factor = 1.1
end
