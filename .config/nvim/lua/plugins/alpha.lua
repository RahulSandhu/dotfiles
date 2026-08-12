-- Dashboard
return {
	"goolord/alpha-nvim",
	enabled = true,
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Header
		dashboard.section.header.val = {
			"oooo   oooo ooooooooooo  ooooooo  ooooo  oooo ooooo oooo     oooo ",
			" 8888o  88   888    88 o888   888o 888    88   888   8888o   888  ",
			" 88 888o88   888ooo8   888     888  888  88    888   88 888o8 88  ",
			" 88   8888   888    oo 888o   o888   88888     888   88  888  88  ",
			"o88o    88  o888ooo8888  88ooo88      888     o888o o88o  8  o88o ",
			"                                                                 ",
		}

		-- Buttons
		dashboard.section.buttons.val = {
			dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("f", "󰈞  > Find file", ":Telescope find_files no_ignore=true<CR>"),
			dashboard.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
			dashboard.button("s", "  > Settings", ":e $MYVIMRC | :cd %:p:h<cr>"),
			dashboard.button("q", "󰅚  > Quit NVIM", ":qa<CR>"),
		}

		-- Layout
		dashboard.config.layout = {
			{ type = "padding", val = 5 },
			dashboard.section.header,
			{ type = "padding", val = 2 },
			dashboard.section.buttons,
			{ type = "padding", val = 2 },
		}

		alpha.setup(dashboard.opts)
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])

		vim.api.nvim_create_autocmd("User", {
			pattern = "AlphaReady",
			once = true,
			callback = function()
				vim.cmd("normal! G")
			end,
		})
	end,
}
