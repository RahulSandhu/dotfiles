-- Linters
return {
	"mfussenegger/nvim-lint",
	enabled = true,
	event = "BufWritePost",
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			lua = { "selene" },
			python = { "ruff" },
			markdown = { "markdownlint" },
			go = { "golangci-lint" },
			sql = { "sqlfluff" },
		}

		vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
