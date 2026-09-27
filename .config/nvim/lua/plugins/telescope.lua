-- Fuzzy finder
return {
	"nvim-telescope/telescope.nvim",
	enabled = true,
	dependencies = {
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		{
			"jmbuhr/telescope-zotero.nvim",
			dependencies = {
				{ "kkharji/sqlite.lua" },
			},
		},
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local previewers = require("telescope.previewers")
		local telescope_config = require("telescope.config")

		-- Skip large files in preview
		local new_maker = function(filepath, bufnr, opts)
			opts = opts or {}
			filepath = vim.fn.expand(filepath)
			vim.uv.fs_stat(filepath, function(_, stat)
				if not stat then
					return
				end
				if stat.size > 100000 then
					return
				else
					previewers.buffer_previewer_maker(filepath, bufnr, opts)
				end
			end)
		end

		-- Extend vimgrep arguments
		local vimgrep_arguments = {
			unpack(telescope_config.values.vimgrep_arguments),
		}
		table.insert(vimgrep_arguments, "--glob")
		table.insert(vimgrep_arguments, "!docs/*")

		-- Setup
		telescope.setup({
			defaults = {
				buffer_previewer_maker = new_maker,
				vimgrep_arguments = vimgrep_arguments,
			file_ignore_patterns = {
				"node_modules",
				"%_cache",
				".git/",
				"site_libs",
				".venv",
			},
			layout_strategy = "flex",
			sorting_strategy = "ascending",
			layout_config = {
				prompt_position = "top",
			},
			mappings = require("core.keymaps").telescope(actions),
			},

			pickers = {
				find_files = {
					hidden = false,
					find_command = {
						"rg",
						"--files",
						"--hidden",
						"--glob",
						"!.git/*",
						"--glob",
						"!**/.Rpro.user/*",
						"--glob",
						"!_site/*",
						"--glob",
						"!docs/**/*.html",
						"-L",
					},
				},
			},

			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
		})

		-- Load extensions
		telescope.load_extension("fzf")
		telescope.load_extension("ui-select")
		telescope.load_extension("zotero")
	end,
}
