-- Draw the tabby tabline at the BOTTOM, in the global statusline, instead of
-- the top tabline. Tabby's own config (names, colours, REPL label) is reused
-- untouched; only the tabpage click items (%NT / %T) are stripped because they
-- are tabline-only.

local info = "%r%m%w%=L:%l/%L, Col:%c%V, "
	.. "Words:%{mode()=~#'[vV\x16]'?wordcount().visual_words:wordcount().words}, Char:%o, %P"

-- The rendered tabs only change on these events, so cache them: the statusline
-- function is evaluated far more often than the tabs actually change.
local cache
local function invalidate()
	cache = nil
end

function _G.StatuslineTabs()
	if cache == nil then
		local ok, rendered = pcall(function()
			return require("tabby.tabline").render()
		end)
		cache = ok and rendered:gsub("%%%d*T", "") or ""
	end
	return cache .. info
end

vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.StatuslineTabs()"
vim.o.showtabline = 0

-- tabby's config sets showtabline = 2; re-assert ours once plugins are loaded.
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.o.showtabline = 0
	end,
})

vim.api.nvim_create_autocmd(
	{ "TabNew", "TabClosed", "TabEnter", "WinEnter", "BufEnter", "BufFilePost", "ColorScheme" },
	{ callback = invalidate }
)
