-- Formatters
return {
	"stevearc/conform.nvim",
	enabled = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			-- Formatter options
			formatters = {
				latexindent = {
					prepend_args = { "-g", "/dev/null" },
				},
				stylua = {
					command = vim.fn.expand("~/.local/share/nvim/mason/bin/stylua"),
				},
			},

			-- Formatters by filetype
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_organize_imports", "ruff_format" },
				markdown = { "prettier" },
				json = { "prettier" },
				tex = { "latexindent" },
				go = { "goimports", "gofumpt" },
				rust = { "rustfmt" },
			},

			-- Format on save
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})
	end,
}
