-- Formatters
return {
	"stevearc/conform.nvim",
	enabled = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			-- Formatter options
			formatters = {
				latexindent = {
					prepend_args = { "-g", "/dev/null" },
				},
				stylua = {
					command = vim.fn.expand("~/.local/share/nvim/mason/bin/stylua"),
				},
				-- NOTE: prettier respects .gitignore, and this repo ignores docs/ ;
				-- "--ignore-path /dev/null" stops that, so notes/decks under docs/ get formatted.
				prettier = {
					prepend_args = { "--print-width", "200", "--ignore-path", "/dev/null" },
				},
				-- markdown-specific prettier: wrap prose at 80 columns.
				-- Slidev decks (docs/meetings/**) are picked up by
				-- docs/meetings/.prettierrc.json, which selects the `slidev`
				-- parser from prettier-plugin-slidev. Without it the default
				-- markdown parser turns per-slide `---` frontmatter into an
				-- h2 and drops the slide content.
				prettier_md = {
					command = vim.fn.expand("~/.local/share/nvim/mason/bin/prettier"),
					args = {
						"--ignore-path",
						"/dev/null",
						"--stdin-filepath",
						"$FILENAME",
						"--prose-wrap",
						"always",
						"--print-width",
						"80",
					},
				},
				["bibtex-tidy"] = {
					command = vim.fn.expand("~/.npm-global/bin/bibtex-tidy"),
					args = {
						"--quiet",
						"--space=2",
						"--align=14",
						"--wrap=80",
						"--blank-lines",
					},
				},
			},

			-- Formatters by filetype
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_organize_imports", "ruff_format" },
				markdown = { "prettier_md" },
				json = { "prettier" },
				tex = { "latexindent" },
				bib = { "bibtex-tidy" },
				go = { "goimports", "gofumpt" },
				sql = { "sqlfluff" },
				r = { "air" },
				rmd = { "air" },
			},

			-- Format on save
			format_on_save = function(bufnr)
				return {
					lsp_fallback = true,
					async = false,
					timeout_ms = 3000,
				}
			end,
		})
	end,
}
