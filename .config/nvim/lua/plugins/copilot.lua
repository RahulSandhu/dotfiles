-- AI code suggestions
return {
	"zbirenbaum/copilot.lua",
	enabled = true,
	event = "InsertEnter",
	cmd = { "Copilot" },
	opts = {
		-- Enabled filetypes
		filetypes = {
			markdown = true,
		},

		-- Keymaps for Copilot
		suggestion = {
			enabled = true,
			auto_trigger = true,
			debounce = 75,
			keymap = require("core.keymaps").copilot,
		},
	},
}
