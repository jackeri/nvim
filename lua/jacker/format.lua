return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function ()
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
				lua = { "stylua" },
			},
		})
	end
}
