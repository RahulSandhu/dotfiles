-- This plugin sends the current working directory to zellij-ide whenever the
-- user changes directories.
local M = {}
function M:setup()
	-- Register a callback for the "cd" command to send the cwd to zellij-ide
	ps.sub("cd", function(_body)
		local cwd = cx.active.current.cwd
		if not cwd then
			return
		end

		-- Convert the cwd to a string and check if it's valid
		local path = tostring(cwd)
		if not path or path == "" or path == "nil" then
			return
		end

		-- Send the current working directory to zellij-ide using zellij pipe
		local quoted = ya.quote(path)
		os.execute("zellij pipe --name yazi-cwd -- " .. quoted .. " > /dev/null 2>&1 &")
	end)
end

return M
