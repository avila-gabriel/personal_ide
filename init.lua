vim.o.paste = false
vim.o.backspace = "indent,eol,start"
vim.o.mouse = "a"
vim.o.termguicolors = true
vim.o.number = true
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.g.mapleader = " "

vim.g.node_host_prog = [[C:\Program Files\nodejs\node_modules\neovim\bin\cli.js]]

vim.api.nvim_create_user_command("ReloadRemotePlugins", "UpdateRemotePlugins", {})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins", {
	checker = { enabled = true },
})

-- activate your theme
vim.cmd.colorscheme("custom_colorscheme")
vim.opt.guifont = "JetBrainsMono Nerd Font:h13"
