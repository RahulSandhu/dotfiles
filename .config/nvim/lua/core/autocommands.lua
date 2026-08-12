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

-- Auto-activate Python virtual environments
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		local bufpath = vim.api.nvim_buf_get_name(0)
		if bufpath == "" then
			return
		end
		local dir = vim.fn.fnamemodify(bufpath, ":h")

		-- Search upward for .venv directory
		local venv_path = vim.fs.find(".venv", {
			path = dir,
			upward = true,
			type = "directory",
		})[1]

		if venv_path then
			local venv_bin = venv_path .. "/bin"
			local venv_python = venv_bin .. "/python"

			if vim.fn.executable(venv_python) == 1 then
				local current_path = vim.env.PATH or ""
				-- Avoid prepending duplicate paths
				if not current_path:find(venv_bin, 1, true) then
					vim.env.PATH = venv_bin .. ":" .. current_path
				end
				vim.env.VIRTUAL_ENV = venv_path
			end
		end
	end,
})

