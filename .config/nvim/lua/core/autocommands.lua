-- Automatically check for file changes
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	pattern = { "*" },
	command = "checktime",
})

-- Highlight the yanked text when copying content
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Remove trailing empty lines at the end of the file on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	desc = "Remove trailing empty lines at EOF",
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		local last_non_empty = #lines
		while last_non_empty > 0 and lines[last_non_empty]:match("^%s*$") do
			last_non_empty = last_non_empty - 1
		end
		if last_non_empty < #lines then
			vim.api.nvim_buf_set_lines(buf, last_non_empty, -1, false, {})
		end
	end,
})
