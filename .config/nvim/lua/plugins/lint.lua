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
		}

		-- nvim-lint already triggers on BufWritePost via the plugin's event.
	end,
}
