-- For conciseness
local M = {}

local function set_keymap(mode, keybinding, command, desc, opts)
	opts = opts or {}
	opts.desc = desc
	vim.keymap.set(mode, keybinding, command, opts)
end

-- General Settings
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

set_keymap("n", "<leader>t", "", "Tabs")
set_keymap("n", "<leader>to", "<cmd>tabnew<CR>", "Open new tab")
set_keymap("n", "<leader>tx", "<cmd>tabclose<CR>", "Close tab")
set_keymap("n", "<leader>tn", "<cmd>tabn<CR>", "Next tab")
set_keymap("n", "<leader>tp", "<cmd>tabp<CR>", "Previous tab")
set_keymap("n", "<leader>tO", "<cmd>tabnew %<CR>", "Open buffer in new tab")

set_keymap("n", "gx", ":!open <c-r><c-a><CR>", "Open URL under cursor")
set_keymap("n", "<leader>hc", ":nohl<CR>", "Clear highlights")

set_keymap("v", ">", ">gv", "Indent and keep selection")
set_keymap("v", "<", "<gv", "Dedent and keep selection")

set_keymap("i", "jk", "<ESC>", "Exit insert mode")
set_keymap("t", "jk", "<C-\\><C-n>", "Exit terminal mode")

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

-- Iron
set_keymap("n", "<leader>r", "", "REPL")
set_keymap("n", "<leader>rr", ":IronRepl<cr>", "Toggle REPL")
set_keymap("n", "<leader>rf", ":IronFocus<cr>", "Focus REPL")
set_keymap("n", "<leader>rh", ":IronHide<cr>", "Hide REPL")
set_keymap("n", "<leader>rR", ":IronRestart<cr>", "Restart REPL")
set_keymap("n", "<leader>rl", function()
	require("iron.core").send_line()
end, "Send line")
set_keymap("n", "<leader>rp", function()
	require("iron.core").send_paragraph()
end, "Send paragraph")
set_keymap("x", "<leader>rs", function()
	require("iron.core").visual_send()
end, "Send selection")

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

-- MarkdownPreview
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
	{ "ys", "<Plug>(nvim-surround-normal)", mode = "n", desc = "Add surround" },
	{ "yss", "<Plug>(nvim-surround-normal-cur)", mode = "n", desc = "Add surround around line" },
	{ "ds", "<Plug>(nvim-surround-delete)", mode = "n", desc = "Delete surround" },
	{ "cs", "<Plug>(nvim-surround-change)", mode = "n", desc = "Change surround" },
	{ "S", "<Plug>(nvim-surround-visual)", mode = "x", desc = "Add surround to selection" },
	{ "gS", "<Plug>(nvim-surround-visual-line)", mode = "x", desc = "Add line surround to selection" },
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

return M
