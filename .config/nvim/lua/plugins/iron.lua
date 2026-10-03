-- REPL
return {
	"hkupty/iron.nvim",
	enabled = true,
	cmd = { "IronRepl", "IronFocus", "IronHide", "IronRestart" },
	config = function()
		local iron = require("iron.core")
		local common = require("iron.fts.common")
		local os = require("os")

		-- sqlite3 connected to the project's DB: project root is the nearest
		-- ancestor holding .git; the DB is the single SQLite file in <root>/data.
		-- Falls back to an in-memory DB when that can't be resolved.
		local function sqlite_command(meta)
			local buf = (meta and meta.current_bufnr) or 0
			local name = vim.api.nvim_buf_get_name(buf)
			local start = name ~= "" and vim.fn.fnamemodify(name, ":p:h") or vim.fn.getcwd()
			local root = vim.fs.root(start, ".git")
			if root then
				local data = root .. "/data"
				if vim.fn.isdirectory(data) == 1 then
					local dbs = {}
					for fname, ftype in vim.fs.dir(data) do
						if ftype == "file" and (fname:match("%.sqlite3?$") or fname:match("%.db$")) then
							dbs[#dbs + 1] = data .. "/" .. fname
						end
					end
					if #dbs == 1 then
						return { "sqlite3", dbs[1] }
					end
				end
			end
			return { "sqlite3" }
		end

		iron.setup({
			config = {
				scratch_repl = true,
				repl_definition = {
					python = {
						command = { "ipython", "--no-autoindent" },
						format = common.bracketed_paste_python,
					},
					r = {
						command = { "R", "--no-save" },
						format = common.bracketed_paste,
					},
					sql = { command = sqlite_command },
					matlab = {
						command = {
							os.getenv("HOME") .. "/.local/share/MATLAB/R2025b/bin/matlab",
							"-nodesktop",
							"-nosplash",
						},
						-- MATLAB's Qt/CEF window stack is X11-only; the Wayland vars
						-- exported in .zshrc break figure windows. Force xcb for MATLAB.
						env = { QT_QPA_PLATFORM = "xcb" },
					},
					go = { command = { "yaegi" } },
				},
				repl_open_cmd = "tabnew",
			},
		})
	end,
}
