-- Tabline
return {
	"nanozuki/tabby.nvim",
	config = function()
		local theme = {
			fill = { bg = "#000000" }, -- tabline background
			sel = { fg = "#000000", bg = "#b8d9ae", style = "bold" }, -- selected tab (accent green)
			tab = { fg = "#6e6e70", bg = "#000000" }, -- inactive tabs
		}

		require("tabby").setup({
			option = {
				buf_name = {
					mode = "tail", -- show only the filename, not long paths
					override = function(bufid)
						-- iron REPL / :terminal buffers get a sane label
						if vim.bo[bufid].buftype == "terminal" then
							return "REPL"
						end
					end,
				},
			},
			line = function(line)
				return {
					{
						line.tabs().foreach(function(tab, i)
							local hl = tab.is_current() and theme.sel or theme.tab
							local block = { " ", tab.name(), " ", hl = hl }
							-- one fill-coloured cell between tabs, but none before the first
							if i == 1 then
								return block
							end
							return { { " ", hl = theme.fill }, block }
						end),
						-- end on the fill highlight, otherwise the empty part of the
						-- tabline inherits the selected tab's colour (whole line green)
						{ " ", hl = theme.fill },
						hl = theme.fill,
					},
				}
			end,
		})

		vim.o.showtabline = 2 -- always show the tabline
		vim.o.sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize"
	end,
}
