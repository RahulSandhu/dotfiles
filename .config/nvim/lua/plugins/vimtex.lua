-- LaTeX
return {
	"lervag/vimtex",
	enabled = true,
	lazy = false,
	init = function()
		vim.g.vimtex_view_method = "zathura_simple"
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_quickfix_enabled = 0

		-- vim.g.vimtex_compiler_latexmk = {
		--    out_dir = "build",
		-- }
	end,
}
