-- Treesitter
return {
	"nvim-treesitter/nvim-treesitter",
	enabled = true,
	branch = "main",
	build = ":TSUpdate",
	config = function()
		-- Explicitly install parsers on first startup (sync, returns instantly once done)
		require("nvim-treesitter").install({
			"r",
			"rnoweb",
			"python",
			"markdown",
			"markdown_inline",
			"yaml",
			"bash",
			"lua",
			"latex",
			"vim",
			"rust",
		}):wait(300000)

		-- Enable treesitter features per filetype
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"r",
				"rnoweb",
				"python",
				"markdown",
				"yaml",
				"bash",
				"lua",
				"tex",
				"vim",
				"rust",
			},
			callback = function()
				-- Core highlighting (Neovim built-in)
				vim.treesitter.start()

				-- Indentation (nvim-treesitter plugin)
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

				-- Folding (Neovim built-in)
				vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.wo.foldmethod = "expr"
			end,
		})
	end,
}
