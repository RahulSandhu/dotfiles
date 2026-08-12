-- Indent scope
return {
	"nvim-mini/mini.indentscope",
	enabled = true,
	version = false,
	opts = function()
		local animation = require("mini.indentscope").gen_animation
		return {
			symbol = "│",
			options = { try_as_border = true },
			draw = {
				animation = animation.none(),
			},
		}
	end,
	init = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "NvimTree", "alpha" },
			callback = function()
				vim.b.miniindentscope_disable = true
			end,
		})
	end,
}
