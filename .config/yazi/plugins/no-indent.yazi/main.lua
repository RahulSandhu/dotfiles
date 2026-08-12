local function setup()
	-- Small 1-cell left indent for the current file pane
	Tab.build = function(self)
		local c = self._chunks
		local p = c[2].w > 0 and 0 or 1
		self._children = {
			Parent:new(c[1]:pad(ui.Pad(0, p, 0, 1)), self._tab),
			Current:new(c[2]:pad(ui.Pad(0, 1, 0, 1)), self._tab),
			Preview:new(c[3]:pad(ui.Pad(0, 1, 0, p)), self._tab),
			Rails:new(c, self._tab),
			Markers:new(c, self._tab),
		}
	end

	-- Remove the leading space before every file/folder name
	Entity.padding = function() return "" end
end

return { setup = setup }
