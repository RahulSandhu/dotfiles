-- Surround
return {
	"kylechui/nvim-surround",
	enabled = true,
	version = "*",
	init = function()
		vim.g.nvim_surround_no_mappings = true
	end,
	keys = require("core.keymaps").surround,
	config = true,
}
