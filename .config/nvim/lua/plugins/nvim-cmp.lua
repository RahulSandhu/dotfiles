-- Autocompletion
return {
	"hrsh7th/nvim-cmp",
	enabled = true,
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lsp-signature-help",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-calc",
		"hrsh7th/cmp-emoji",
		"f3fora/cmp-spell",
		"ray-x/cmp-treesitter",
		"kdheepak/cmp-latex-symbols",
		"jmbuhr/cmp-pandoc-references",
		"onsails/lspkind-nvim",
		"jalvesaq/cmp-nvim-r",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"rafamadriz/friendly-snippets",
	},
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")

		-- Highlights
		local function set_cmp_highlights()
			vim.api.nvim_set_hl(0, "CmpPmenu", { fg = "#e0e0e0", bg = "#000000" })
			vim.api.nvim_set_hl(0, "CmpDoc", { fg = "#e0e0e0", bg = "#000000" })
			vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#4a5d46", bg = "#000000" })
			vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#000000", bg = "#b8d9ae", bold = true })
		end

		set_cmp_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", {
			callback = set_cmp_highlights,
		})

		-- Snippets
		require("luasnip.loaders.from_vscode").lazy_load()

		-- Setup
		cmp.setup({
			performance = {
				debounce = 80,
				throttle = 40,
				fetching_timeout = 250,
			},

			completion = { completeopt = "menu,menuone,noinsert" },

			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},

			mapping = require("core.keymaps").cmp(cmp),

			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = lspkind.cmp_format({
					mode = "symbol",
					maxwidth = 50,
					ellipsis_char = "...",
					menu = {
						nvim_lsp = "[LSP]",
						luasnip = "[Snip]",
						nvim_lsp_signature_help = "[Sig]",
						buffer = "[Buf]",
						path = "[Path]",
						spell = "[Spell]",
						pandoc_references = "[Ref]",
						treesitter = "[TS]",
						calc = "[Calc]",
						latex_symbols = "[TeX]",
						emoji = "[Emoji]",
						cmp_nvim_r = "[R]",
					},
				}),
			},

			sources = {
				{ name = "luasnip" },
				{ name = "path" },
				{ name = "nvim_lsp_signature_help" },
				{ name = "nvim_lsp" },
				{ name = "pandoc_references", keyword_length = 4, max_item_count = 6 },
				{ name = "buffer", keyword_length = 6, max_item_count = 3 },
				{ name = "spell", keyword_length = 4, max_item_count = 5 },
				{ name = "treesitter", keyword_length = 6, max_item_count = 2 },
				{ name = "calc" },
				{ name = "latex_symbols" },
				{ name = "emoji" },
				{ name = "cmp_nvim_r", filetypes = { "r", "rmd" } },
			},

			window = {
				completion = cmp.config.window.bordered({
					winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
				}),
				documentation = cmp.config.window.bordered({
					winhighlight = "Normal:CmpDoc,FloatBorder:CmpBorder",
				}),
			},
		})

		-- Filetype overrides
		cmp.setup.filetype({ "markdown", "quarto", "rmd" }, {
			sources = {
				{ name = "luasnip" },
				{ name = "nvim_lsp" },
				{ name = "nvim_lsp_signature_help" },
				{ name = "path" },
				{ name = "pandoc_references", keyword_length = 4, max_item_count = 8 },
				{ name = "treesitter", keyword_length = 6, max_item_count = 2 },
				{ name = "spell", keyword_length = 4, max_item_count = 6 },
				{ name = "buffer", keyword_length = 6, max_item_count = 4 },
				{ name = "emoji" },
			},
		})

		cmp.setup.filetype("tex", {
			sources = {
				{ name = "nvim_lsp" },
				{ name = "latex_symbols" },
				{ name = "path" },
				{ name = "spell", keyword_length = 4, max_item_count = 6 },
				{ name = "buffer", keyword_length = 6, max_item_count = 4 },
			},
		})
	end,
}
