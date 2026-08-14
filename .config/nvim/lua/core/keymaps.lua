-- For conciseness
local M = {}

local function set_keymap(mode, keybinding, command, desc, opts)
	opts = opts or {}
	opts.desc = desc
	vim.keymap.set(mode, keybinding, command, opts)
end

-- NeoVim settings
set_keymap("n", "<leader>v", "", "Vim settings")
set_keymap("n", "<leader>vS", ":w<cr>:source %<cr>", "Source file")
set_keymap("n", "<leader>vh", ':execute "h " . expand("<cword>")<cr>', "Help word")
set_keymap("n", "<leader>vl", ":Lazy<cr>", "Lazy manager")
set_keymap("n", "<leader>vm", ":Mason<cr>", "Mason installer")
set_keymap("n", "<leader>vs", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k<cr>", "Settings file")

set_keymap("n", "<leader>wq", ":wq<CR>", "Save and quit")
set_keymap("n", "<leader>qq", ":q!<CR>", "Quit without saving")
set_keymap("n", "<leader>ww", ":w<CR>", "Save")
set_keymap("n", "<C-s>", "<cmd>:update<cr><esc>", "Save")

set_keymap("n", "gx", ":!open <c-r><c-a><CR>", "Open URL under cursor")
set_keymap("n", "<leader>hc", ":nohl<CR>", "Clear highlights")

set_keymap("v", ">", ">gv", "Indent and keep selection")
set_keymap("v", "<", "<gv", "Dedent and keep selection")

set_keymap("i", "jk", "<ESC>", "Exit insert mode")

-- Alpha
set_keymap("n", "<leader>a", ":Alpha<cr>", "Open [a]lpha dashboard")

-- Comment
set_keymap("n", "gcc", function()
	return vim.v.count == 0 and "<Plug>(comment_toggle_linewise_current)" or "<Plug>(comment_toggle_linewise_count)"
end, "Toggle current line comment", { expr = true })
set_keymap("n", "gc", "<Plug>(comment_toggle_linewise)", "Toggle linewise comment")

set_keymap("x", "gc", "<Plug>(comment_toggle_linewise_visual)", "Toggle linewise comment")

-- cmp
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

-- Gitsigns
set_keymap("n", "]h", function()
	require("gitsigns").nav_hunk("next")
end, "Next hunk")
set_keymap("n", "[h", function()
	require("gitsigns").nav_hunk("prev")
end, "Previous hunk")
set_keymap("n", "<leader>hs", function()
	require("gitsigns").stage_hunk()
end, "Stage hunk")
set_keymap("n", "<leader>hr", function()
	require("gitsigns").reset_hunk()
end, "Reset hunk")
set_keymap("n", "<leader>hp", function()
	require("gitsigns").preview_hunk()
end, "Preview hunk")

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local buf = args.buf
		set_keymap("n", "<leader>g", "", "Language server", { buffer = buf })
		set_keymap("n", "K", vim.lsp.buf.hover, "Hover", { buffer = buf })
		set_keymap("n", "<leader>gd", vim.lsp.buf.definition, "Definition", { buffer = buf })
		set_keymap("n", "<leader>gr", vim.lsp.buf.references, "References", { buffer = buf })
		set_keymap("n", "<leader>ga", vim.lsp.buf.code_action, "Code action", { buffer = buf })
		set_keymap("n", "<leader>gf", function()
			vim.lsp.buf.format({ async = true })
		end, "Format", { buffer = buf })
		set_keymap("n", "<leader>gg", vim.diagnostic.open_float, "Diagnostics", { buffer = buf })
		set_keymap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic", { buffer = buf })
		set_keymap("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic", { buffer = buf })
	end,
})

-- Markdown preview
set_keymap("n", "<leader>mp", ":MarkdownPreviewToggle<CR>", "Toggle markdown preview")

-- Multiline
M.multiline = {
	{ "<C-n>", mode = { "n", "x" }, desc = "Find word under cursor" },

	{ "\\A", mode = "n", desc = "Select all occurrences of word" },
	{ "\\/", mode = "n", desc = "Start regex cursor search" },

	{ "\\A", mode = "x", desc = "Select all occurrences of selection" },
	{ "\\/", mode = "x", desc = "Regex search visual selection" },
}

-- Surround
M.surround = {
	{ "ys", "<Plug>(nvim-surround-normal)", mode = "n", expr = true, desc = "Add surround" },
	{ "yss", "<Plug>(nvim-surround-normal-cur)", mode = "n", expr = true, desc = "Add surround around line" },
	{ "ds", "<Plug>(nvim-surround-delete)", mode = "n", expr = true, desc = "Delete surround" },
	{ "cs", "<Plug>(nvim-surround-change)", mode = "n", expr = true, desc = "Change surround" },
	{ "S", "<Plug>(nvim-surround-visual)", mode = "x", expr = true, desc = "Add surround to selection" },
	{ "gS", "<Plug>(nvim-surround-visual-line)", mode = "x", expr = true, desc = "Add line surround to selection" },
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

set_keymap("n", "<leader>f", "", "Telescope")
set_keymap("n", "<leader>ff", "<cmd>Telescope find_files no_ignore=true<cr>", "Find files")
set_keymap("n", "<leader>fb", "<cmd>Telescope buffers hidden=true<cr>", "Find buffers")
set_keymap("n", "<leader>fr", "<cmd>Telescope oldfiles hidden=true<cr>", "Recent files")
set_keymap("n", "<leader>fs", "<cmd>Telescope live_grep hidden=true<cr>", "Find string in cwd")
set_keymap("n", "<leader>fc", "<cmd>Telescope grep_string hidden=true<cr>", "Find string under cursor")
set_keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", "Help tags")
set_keymap("n", "<leader>fo", "<cmd>Telescope lsp_document_symbols hidden=true<cr>", "LSP symbols")
set_keymap("n", "<leader>fi", "<cmd>Telescope lsp_incoming_calls hidden=true<cr>", "LSP incoming calls")
set_keymap("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", "Keymaps")
set_keymap("n", "<leader>fq", "<cmd>Telescope quickfix<cr>", "Quickfix")
set_keymap("n", "<leader>fp", "<cmd>Telescope neoclip<cr>", "Paste history")
set_keymap("n", "<leader>fz", "<cmd>Telescope zotero<cr>", "Zotero references")
set_keymap("n", "fz", ":Telescope spell_suggest<cr>", "Spell suggestions")

-- VimTeX
set_keymap("n", ",li", "<Plug>(vimtex-info)", "Vimtex info")
set_keymap("n", ",lI", "<Plug>(vimtex-info-full)", "Vimtex info full")
set_keymap("n", ",lt", "<Plug>(vimtex-toc-open)", "Open table of contents")
set_keymap("n", ",lT", "<Plug>(vimtex-toc-toggle)", "Toggle table of contents")
set_keymap("n", ",ly", "<Plug>(vimtex-labels-open)", "Open labels")
set_keymap("n", ",lY", "<Plug>(vimtex-labels-toggle)", "Toggle labels")
set_keymap("n", ",lv", "<Plug>(vimtex-view)", "View PDF")
set_keymap("n", ",lr", "<Plug>(vimtex-reverse-search)", "Reverse search")
set_keymap("n", ",ll", "<Plug>(vimtex-compile-toggle)", "Latex compile toggle")
set_keymap("n", ",lk", "<Plug>(vimtex-stop)", "Kill compilation")
set_keymap("n", ",lK", "<Plug>(vimtex-stop-all)", "Kill all compilations")
set_keymap("n", ",le", "<Plug>(vimtex-errors)", "Show errors")
set_keymap("n", ",lo", "<Plug>(vimtex-compile-output)", "Show compile output")
set_keymap("n", ",lg", "<Plug>(vimtex-status)", "Show status")
set_keymap("n", ",lG", "<Plug>(vimtex-status-all)", "Show status all")
set_keymap("n", ",lc", "<Plug>(vimtex-clean)", "Clean build files")
set_keymap("n", ",lC", "<Plug>(vimtex-clean-full)", "Clean build files full")
set_keymap("n", ",lm", "<Plug>(vimtex-imaps-list)", "Show imaps")
set_keymap("n", ",lx", "<Plug>(vimtex-reload)", "Reload")
set_keymap("n", ",ls", "<Plug>(vimtex-toggle-main)", "Toggle main subfile")

return M
