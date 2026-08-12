local M = {}

local function set_keymap(mode, keybinding, command, desc, opts)
	opts = opts or {}
	opts.desc = desc
	vim.keymap.set(mode, keybinding, command, opts)
end

function M.setup()
	-- Neovim
	set_keymap("n", "<leader>v", "", "[v]im settings")
	set_keymap("n", "<leader>vl", ":Lazy<CR>", "[l]azy manager")
	set_keymap("n", "<leader>vm", ":Mason<CR>", "[m]ason installer")
	set_keymap("i", "jk", "<ESC>", "exit insert mode")
	set_keymap("v", "<Tab>", "<ESC>", "exit visual mode")
	set_keymap("n", "gx", ":!firefox <C-r><C-a><CR>", "[o]pen URL under cursor")
	set_keymap("n", "<leader>nh", ":nohl<CR>", "[n]o [h]ighlight")
	set_keymap("v", ">", ">gv", "indent selection")
	set_keymap("v", "<", "<gv", "dedent selection")
	set_keymap("n", "<C-s>", "<cmd>update<CR><ESC>", "save")
	set_keymap("n", "<leader>ww", ":w<CR>", "save")
	set_keymap("n", "<leader>wq", ":wq<CR>", "save and [q]uit")
	set_keymap("n", "<leader>qq", ":q!<CR>", "[q]uit without saving")
	set_keymap("i", "<M-.>", "<-", "R assignment")
	set_keymap("i", "<M-m>", "|>", "R pipe")

	-- Comment
	set_keymap("n", "gc", "<Plug>(comment_toggle_linewise)", "toggle linewise comment")
	set_keymap("n", "gb", "<Plug>(comment_toggle_blockwise)", "toggle blockwise comment")
	set_keymap("n", "gcc", function()
		return vim.v.count == 0 and "<Plug>(comment_toggle_linewise_current)" or "<Plug>(comment_toggle_linewise_count)"
	end, "toggle current line comment", { expr = true })
	set_keymap("n", "gbc", function()
		return vim.v.count == 0 and "<Plug>(comment_toggle_blockwise_current)"
			or "<Plug>(comment_toggle_blockwise_count)"
	end, "toggle current block comment", { expr = true })
	set_keymap("x", "gc", "<Plug>(comment_toggle_linewise_visual)", "toggle linewise comment")
	set_keymap("x", "gb", "<Plug>(comment_toggle_blockwise_visual)", "toggle blockwise comment")
	set_keymap("n", "gco", require("Comment.api").insert.linewise.below, "insert comment below")
	set_keymap("n", "gcO", require("Comment.api").insert.linewise.above, "insert comment above")
	set_keymap("n", "gcA", require("Comment.api").locked("insert.linewise.eol"), "insert comment at end of line")

	-- Gitsigns
	set_keymap("n", "]h", function()
		if vim.wo.diff then
			vim.cmd.normal({ "]h", bang = true })
		else
			require("gitsigns").nav_hunk("next")
		end
	end, "next hunk")
	set_keymap("n", "[h", function()
		if vim.wo.diff then
			vim.cmd.normal({ "[h", bang = true })
		else
			require("gitsigns").nav_hunk("prev")
		end
	end, "previous hunk")
	set_keymap("n", "<leader>h", "", "[h]unk")
	set_keymap("n", "<leader>hs", function()
		require("gitsigns").stage_hunk()
	end, "[s]tage hunk")
	set_keymap("n", "<leader>hr", function()
		require("gitsigns").reset_hunk()
	end, "[r]eset hunk")
	set_keymap("v", "<leader>hs", function()
		require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, "[s]tage hunk")
	set_keymap("v", "<leader>hr", function()
		require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
	end, "[r]eset hunk")
	set_keymap("n", "<leader>hS", function()
		require("gitsigns").stage_buffer()
	end, "[S]tage buffer")
	set_keymap("n", "<leader>hR", function()
		require("gitsigns").reset_buffer()
	end, "[R]eset buffer")
	set_keymap("n", "<leader>hp", function()
		require("gitsigns").preview_hunk()
	end, "[p]review hunk")
	set_keymap("n", "<leader>hi", function()
		require("gitsigns").preview_hunk_inline()
	end, "preview hunk [i]nline")
	set_keymap("n", "<leader>hb", function()
		require("gitsigns").blame_line({ full = true })
	end, "[b]lame line")
	set_keymap("n", "<leader>hd", function()
		require("gitsigns").diffthis()
	end, "[d]iff against index")
	set_keymap("n", "<leader>hD", function()
		require("gitsigns").diffthis("~")
	end, "[D]iff against previous revision")
	set_keymap("n", "<leader>hq", function()
		require("gitsigns").setqflist()
	end, "[q]uickfix hunks")
	set_keymap("n", "<leader>hQ", function()
		require("gitsigns").setqflist("all")
	end, "[Q]uickfix all changes")
	set_keymap("n", "<leader>tb", function()
		require("gitsigns").toggle_current_line_blame()
	end, "[t]oggle [b]lame")
	set_keymap("n", "<leader>tw", function()
		require("gitsigns").toggle_word_diff()
	end, "[t]oggle [w]ord diff")
	set_keymap({ "o", "x" }, "ih", function()
		require("gitsigns").select_hunk()
	end, "select hunk")

	-- LaTeX
	set_keymap("n", ",li", "<Plug>(vimtex-info)", "vimtex [i]nfo")
	set_keymap("n", ",lI", "<Plug>(vimtex-info-full)", "vimtex [I]nfo full")
	set_keymap("n", ",lt", "<Plug>(vimtex-toc-open)", "open [t]able of contents")
	set_keymap("n", ",lT", "<Plug>(vimtex-toc-toggle)", "[T]oggle table of contents")
	set_keymap("n", ",ly", "<Plug>(vimtex-labels-open)", "open [y]abels")
	set_keymap("n", ",lY", "<Plug>(vimtex-labels-toggle)", "[Y]oggle labels")
	set_keymap("n", ",lv", "<Plug>(vimtex-view)", "[v]iew PDF")
	set_keymap("n", ",lr", "<Plug>(vimtex-reverse-search)", "[r]everse search")
	set_keymap("n", ",ll", "<Plug>(vimtex-compile-toggle)", "[l]atex compile toggle")
	set_keymap("n", ",lk", "<Plug>(vimtex-stop)", "[k]ill compilation")
	set_keymap("n", ",lK", "<Plug>(vimtex-stop-all)", "[K]ill all compilations")
	set_keymap("n", ",le", "<Plug>(vimtex-errors)", "show [e]rrors")
	set_keymap("n", ",lo", "<Plug>(vimtex-compile-output)", "show compile [o]utput")
	set_keymap("n", ",lg", "<Plug>(vimtex-status)", "show status [g]")
	set_keymap("n", ",lG", "<Plug>(vimtex-status-all)", "show status all [G]")
	set_keymap("n", ",lc", "<Plug>(vimtex-clean)", "[c]lean build files")
	set_keymap("n", ",lC", "<Plug>(vimtex-clean-full)", "[C]lean build files full")
	set_keymap("n", ",lm", "<Plug>(vimtex-imaps-list)", "show i[m]aps")
	set_keymap("n", ",lx", "<Plug>(vimtex-reload)", "reloa[x]")
	set_keymap("n", ",ls", "<Plug>(vimtex-toggle-main)", "toggle main [s]ubfile")

	-- LaTeX: edit commands
	set_keymap("n", "dse", "<Plug>(vimtex-env-delete)", "delete surrounding env")
	set_keymap("n", "dsc", "<Plug>(vimtex-cmd-delete)", "delete surrounding command")
	set_keymap("n", "ds$", "<Plug>(vimtex-env-delete-math)", "delete surrounding math")
	set_keymap("n", "cse", "<Plug>(vimtex-env-change)", "change surrounding env")
	set_keymap("n", "csc", "<Plug>(vimtex-cmd-change)", "change surrounding command")
	set_keymap("n", "cs$", "<Plug>(vimtex-cmd-change-math)", "change surrounding math")
	set_keymap("n", "tse", "<Plug>(vimtex-env-toggle-star)", "toggle env star")
	set_keymap({ "n", "x" }, "tsd", "<Plug>(vimtex-delim-toggle-modifier)", "toggle delimiter modifier")
	set_keymap({ "n", "i" }, "<F7>", "<Plug>(vimtex-cmd-create)", "create command")
	set_keymap("i", "]]", "<Plug>(vimtex-delim-close)", "close delimiter")

	-- LaTeX: text objects
	set_keymap({ "x", "o" }, "ac", "<Plug>(vimtex-ac)", "around command")
	set_keymap({ "x", "o" }, "ic", "<Plug>(vimtex-ic)", "inside command")
	set_keymap({ "x", "o" }, "ad", "<Plug>(vimtex-ad)", "around delimiter")
	set_keymap({ "x", "o" }, "id", "<Plug>(vimtex-id)", "inside delimiter")
	set_keymap({ "x", "o" }, "ae", "<Plug>(vimtex-ae)", "around environment")
	set_keymap({ "x", "o" }, "ie", "<Plug>(vimtex-ie)", "inside environment")
	set_keymap({ "x", "o" }, "a$", "<Plug>(vimtex-a$)", "around math")
	set_keymap({ "x", "o" }, "i$", "<Plug>(vimtex-i$)", "inside math")

	-- LaTeX: navigation
	set_keymap({ "n", "x", "o" }, "%", "<Plug>(vimtex-%)", "match delimiter")
	set_keymap({ "n", "x", "o" }, "]]", "<Plug>(vimtex-]])", "next section start")
	set_keymap({ "n", "x", "o" }, "][", "<Plug>(vimtex-][)", "next section end")
	set_keymap({ "n", "x", "o" }, "[]", "<Plug>(vimtex-[])", "previous section end")
	set_keymap({ "n", "x", "o" }, "[[", "<Plug>(vimtex-[[)", "previous section start")

	-- LSP
	set_keymap("n", "<leader>g", "", "lan[g]uage server")
	set_keymap("n", "<leader>gh", "<cmd>lua vim.lsp.buf.hover()<CR>", "LSP [h]over")
	set_keymap("n", "<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>", "go to [d]efinition")
	set_keymap("n", "<leader>gc", "<cmd>lua vim.lsp.buf.declaration()<CR>", "go to de[c]laration")
	set_keymap("n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", "go to [i]mplementation")
	set_keymap("n", "<leader>gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", "go to [t]ype")
	set_keymap("n", "<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>", "show [r]eferences")
	set_keymap("n", "<leader>gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", "[s]ignature help")
	set_keymap("n", "<leader>gf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", "[f]ormat")
	set_keymap("n", "<leader>ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", "code [a]ction")
	set_keymap("n", "<leader>gg", "<cmd>lua vim.diagnostic.open_float()<CR>", "open dia[g]nostics")
	set_keymap("n", "<leader>gp", "<cmd>lua vim.diagnostic.goto_prev()<CR>", "[p]revious diagnostic")
	set_keymap("n", "<leader>gn", "<cmd>lua vim.diagnostic.goto_next()<CR>", "[n]ext diagnostic")
	set_keymap("n", "<leader>go", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", "[o]pen symbols")
	set_keymap("v", "<leader>fc", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", "[f]ormat code")

	-- Markdown preview
	set_keymap("n", "<leader>m", "", "[m]arkdown preview")
	set_keymap("n", "<leader>mp", ":MarkdownPreviewToggle<CR>", "toggle [p]review")
	set_keymap("n", "<leader>ms", ":MarkdownPreview<CR>", "[s]tart preview")
	set_keymap("n", "<leader>mS", ":MarkdownPreviewStop<CR>", "[S]top preview")

	-- Telescope
	set_keymap("n", "<leader>f", "", "telescope fuzzy [f]inder")
	set_keymap("n", "<leader>ff", "<cmd>Telescope find_files no_ignore=true<CR>", "find [f]iles")
	set_keymap("n", "<leader>fb", "<cmd>Telescope buffers hidden=true<CR>", "find [b]uffers")
	set_keymap("n", "<leader>fr", "<cmd>Telescope oldfiles hidden=true<CR>", "[r]ecent files")
	set_keymap("n", "<leader>fs", "<cmd>Telescope live_grep hidden=true<CR>", "find [s]tring in cwd")
	set_keymap("n", "<leader>fc", "<cmd>Telescope grep_string hidden=true<CR>", "find string under [c]ursor")
	set_keymap("n", "<leader>fh", "<cmd>Telescope help_tags hidden=true<CR>", "[h]elp tags")
	set_keymap("n", "<leader>fo", "<cmd>Telescope lsp_document_symbols hidden=true<CR>", "LSP symb[o]ls")
	set_keymap("n", "<leader>fi", "<cmd>Telescope lsp_incoming_calls hidden=true<CR>", "LSP [i]ncoming calls")
	set_keymap("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", "[k]eymaps")
	set_keymap("n", "<leader>fq", "<cmd>Telescope quickfix<CR>", "[q]uickfix")
	set_keymap("n", "<leader>fp", "<cmd>Telescope neoclip<CR>", "open [p]aste history")
	set_keymap("n", "<leader>fz", "<cmd>Telescope zotero<CR>", "[z]otero references")
	set_keymap("n", "fz", ":Telescope spell_suggest<CR>", "spell [z]uggestions")
end

-- CMP
function M.cmp(cmp)
	return cmp.mapping.preset.insert({
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete({}),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = false,
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif require("luasnip").expand_or_jumpable() then
				require("luasnip").expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif require("luasnip").jumpable(-1) then
				require("luasnip").jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	})
end

-- Copilot
M.copilot = {
	accept = "<C-a>",
	accept_word = false,
	accept_line = false,
	next = "<M-]>",
	prev = "<M-[>",
	dismiss = "<C-]>",
}

-- Multiline cursor (vim-visual-multi default mappings)
M.multiline = {
	{ "<C-n>", mode = { "n", "x" }, desc = "find word/subword under cursor" },
	{ "<C-Down>", mode = "n", desc = "add cursor below" },
	{ "<C-Up>", mode = "n", desc = "add cursor above" },
	{ "\\gS", mode = "n", desc = "reselect previous cursors" },
	{ "\\\\", mode = "n", desc = "add cursor at position" },
	{ "\\/", mode = "n", desc = "start regex cursor search" },
	{ "\\A", mode = "n", desc = "select all occurrences of word" },
	{ "\\A", mode = "x", desc = "select all occurrences of selection" },
	{ "\\/", mode = "x", desc = "regex search visual selection" },
	{ "\\a", mode = "x", desc = "add visual selection" },
	{ "\\f", mode = "x", desc = "find visual selection" },
	{ "\\c", mode = "x", desc = "create cursors from selection" },
}


-- Surround
M.surround = {
	{ "<C-g>s", "<Plug>(nvim-surround-insert)", mode = "i", desc = "add surround at cursor" },
	{ "<C-g>S", "<Plug>(nvim-surround-insert-line)", mode = "i", desc = "add line surround at cursor" },
	{ "ys", "<Plug>(nvim-surround-normal)", mode = "n", expr = true, desc = "add surround around motion" },
	{ "yss", "<Plug>(nvim-surround-normal-cur)", mode = "n", expr = true, desc = "add surround around line" },
	{ "yS", "<Plug>(nvim-surround-normal-line)", mode = "n", expr = true, desc = "add line surround around motion" },
	{ "ySS", "<Plug>(nvim-surround-normal-cur-line)", mode = "n", expr = true, desc = "add line surround around line" },
	{ "ds", "<Plug>(nvim-surround-delete)", mode = "n", expr = true, desc = "delete surround" },
	{ "cs", "<Plug>(nvim-surround-change)", mode = "n", expr = true, desc = "change surround" },
	{ "cS", "<Plug>(nvim-surround-change-line)", mode = "n", expr = true, desc = "change surround on new lines" },
	{ "S", "<Plug>(nvim-surround-visual)", mode = "x", expr = true, desc = "add surround to selection" },
	{ "gS", "<Plug>(nvim-surround-visual-line)", mode = "x", expr = true, desc = "add line surround to selection" },
}

-- Telescope
function M.telescope(actions)
	return {
		i = {
			["<C-u>"] = false,
			["<C-d>"] = false,
			["<C-x>"] = actions.close,
			["<C-j>"] = actions.move_selection_next,
			["<C-k>"] = actions.move_selection_previous,
		},
	}
end

return M
