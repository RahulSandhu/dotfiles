-- For conciseness
local opt = vim.opt

-- Enable true colors for better terminal color support
opt.termguicolors = true

-- Remove '~' from empty lines in the buffer
vim.opt.fillchars:append("eob: ")

-- Set colorscheme
local function simple_colors()
	vim.cmd([[highlight Normal guibg=#000000 ctermbg=0]])
	vim.cmd([[highlight NormalNC guibg=#000000 ctermbg=0]])
	vim.cmd([[highlight EndOfBuffer guibg=#000000 ctermbg=0]])
	vim.cmd([[highlight SignColumn guibg=#000000 ctermbg=0]])
	vim.cmd([[highlight LineNr guibg=#000000 ctermbg=0]])
	vim.cmd([[highlight StatusLine guifg=#e0e0e0 guibg=#000000]])
	vim.cmd([[highlight NormalFloat guifg=#e0e0e0 guibg=#000000]])
	vim.cmd([[highlight FloatBorder guifg=#445c3d guibg=#000000 ctermfg=10 ctermbg=0]])
	vim.cmd([[highlight Pmenu guifg=#e0e0e0 guibg=#000000]])
	vim.cmd([[highlight PmenuSel guifg=#000000 guibg=#b8d9ae ctermfg=0 ctermbg=10]])
end

simple_colors()

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = simple_colors,
})

-- Define the highlight group for gitsigns current line blame
vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", {
	fg = "#6e6e70",
	italic = true,
})

-- Keep popups and completion menus fully opaque
vim.opt.winblend = 0
vim.opt.pumblend = 0

-- Display line numbers
opt.number = true
opt.relativenumber = false

-- Configure tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.softtabstop = 2

-- Enable smarter indentation behavior
opt.smartindent = true
opt.breakindent = true

-- Customize backspace behavior
opt.backspace = "indent,eol,start"

-- Set textwidth
opt.textwidth = 79

-- Disable line wrapping
opt.wrap = false
opt.winborder = "single"

-- Enable mouse support and clipboard integration
opt.mouse = "a"
opt.mousefocus = true
opt.clipboard:append("unnamedplus")

-- Search settings
opt.ignorecase = true
opt.smartcase = true

-- Cursor line highlighting
opt.cursorline = true

-- Always show the sign column to avoid shifting the text when signs appear
opt.signcolumn = "yes:1"

-- Configure the command line height
opt.cmdheight = 1

-- Sets the status line content
vim.opt.statusline = "%r%m%w%="
	.. "L:%l/%L, "
	.. "Col:%c%V, "
	.. "Words:%{mode()=~#'[vV\x16]'?wordcount().visual_words:wordcount().words}, "
	.. "Char:%o, "
	.. "%P"

-- Default behavior for window splits
opt.splitright = true
opt.splitbelow = true

-- Keep 5 lines visible when scrolling near the window edges
opt.scrolloff = 5

-- Opinionated settings for better responsiveness
opt.timeoutlen = 400
opt.updatetime = 250
opt.shortmess:append("A")

-- Configure auto-completion menu behavior
opt.completeopt = "menuone,noinsert"

-- Configure the maximum fold level for code folding
opt.foldlevel = 99

-- Disable conceal feature except for minimal text concealment
opt.conceallevel = 0

-- Configure diagnostic display settings
vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	signs = true,
})

-- Spell check settings
opt.spell = true
opt.spelllang = "en_us"

-- Load additional built-in Vim packages
vim.cmd.packadd("cfilter")
