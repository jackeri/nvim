local function uncrustify()
	local cwd = vim.fn.getcwd()
	local cfg = cwd .. '/uncrustify.cfg'
	-- if vim.loop.fs_stat(cfg) then
	-- print('Setting the uncrustify config to: ' .. cfg)
	-- end
	return {
		command = "uncrustify",
		-- cwd = require("conform.util").root_file({ "uncrustify.cfg" }),
		-- args = { "-c", vim.fn.expand("~/.uncrustify.cfg"), "--no-backup", "--replace", "--mtime" },
		-- args = { "-c", cfg, "--no-backup", "--replace", "--mtime", "-l", vim.bo[ctx.buf].filetype:upper() },
		args = function(_, ctx)
			return { "-c", cfg, "-l", vim.bo[ctx.buf].filetype:upper() }
		end,
		condition = function(_)
			return vim.fn.executable("uncrustify") == 1 and vim.loop.fs_stat(cfg)
		end,
		-- stdin = false,
		-- inherit = true,
	}
end

local function is_crustify_available(bufnr)
	if require("conform").get_formatter_info("uncrustify", bufnr).available then
		return { "uncrustify" }
	else
		return { "clang_format" }
	end
end

return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		-- conform.setup({
		-- 	-- The default formatter is prettierV
		-- 	formatter = {
		-- 		exe = "prettier",
		-- 		args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
		-- 		stdin = true,
		-- 	},
		-- 	-- The default linter is eslint
		-- 	linter = {
		-- 		exe = "eslint",
		-- 		args = { "--stdin-filename", vim.api.nvim_buf_get_name(0), "--fix-to-stdout" },
		-- 		stdin = true,
		-- 	},
		-- 	-- The default filetypes are javascript, typescript, and json
		-- 	filetypes = { "javascript", "typescript", "json" },
		-- })
		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				vue = { "prettier" },
				css = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				c = is_crustify_available,
				cpp = is_crustify_available,
				glsl = is_crustify_available,
				lua = { "stylua" },
			},
			formatters = {
				uncrustify = uncrustify,
			},
			format_on_save = {
				lsp_fallback = false,
				async = false,
				timeout_ms = 500,
			},
			notify_on_error = true,
		})
		vim.keymap.set({ "n", "v" }, "<leader>cf", function()
			conform.format({
				lsp_fallback = false,
				async = false,
				timeout_ms = 500,
			})
		end, { desc = "[C]ode [F]ormat" })
	end
}
