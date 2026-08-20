-- REPL
return {
	"hkupty/iron.nvim",
	enabled = true,
	cmd = { "IronRepl", "IronFocus", "IronHide", "IronRestart" },
	config = function()
		local iron = require("iron.core")
		local view = require("iron.view")
		local common = require("iron.fts.common")

		iron.setup({
			config = {
				scratch_repl = true,
				repl_definition = {
					sh = { command = { "zsh" } },
					bash = { command = { "zsh" } },
					zsh = { command = { "zsh" } },
					python = {
						command = { "ipython" },
						format = common.bracketed_paste_python,
						env = { PYTHON_BASIC_REPL = "1" },
					},
					r = {
						command = { "R", "--no-save" },
						format = common.bracketed_paste,
					},
					sql = { command = { "sqlite3" } },
				},
				repl_open_cmd = "tabnew",
			},
		})
	end,
}
