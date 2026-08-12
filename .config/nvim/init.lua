-- Bootstrap lazy.nvim if it's not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Set leader and local leader keys before initializing lazy
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Initialize lazy.nvim and load plugins from the plugins directory
require("lazy").setup("plugins", {
	ui = {
		border = "single",
		size = {
			width = 1,
			height = 1,
		},
	},
	change_detection = {
		enabled = true,
		notify = false,
	},
})

-- Load core settings and modules that are not handled by lazy
require("core.options")
require("core.autocommands")
require("core.keymaps").setup()
