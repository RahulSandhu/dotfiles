-- Obsidian notes
return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- latest stable release
	ft = "markdown",
	opts = {
		legacy_commands = false,
		workspaces = {
			{
				name = "phd",
				path = "~/desktop/studies/biomedical_engineering/phd/docs/notes",
			},
		},
		picker = {
			name = "telescope.nvim",
		},
		frontmatter = {
			sort = { "id", "title", "description", "authors", "tags" },
			-- obsidian.nvim writes an "aliases" field by default; skip it when empty
			func = function(note)
				local out = require("obsidian.builtin").frontmatter(note)
				if vim.tbl_isempty(out.aliases or {}) then
					out.aliases = nil
				end
				return out
			end,
		},
		ui = {
			enable = false, -- Obsidian's syntax UI needs conceallevel=2
		},
	},
}
