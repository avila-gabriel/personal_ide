return {
	{ "rose-pine/neovim", name = "rose-pine" },
	{ "catppuccin/nvim", name = "catppuccin" },
	{ "Mofiqul/dracula.nvim" },
	{ "EdenEast/nightfox.nvim" },
	{ "vague2k/vague.nvim" },
	{ "anAcc22/sakura.nvim" },
	{ "rktjmp/lush.nvim" },
	{ "savq/melange-nvim", name = "melange" },
	{
		"comfysage/evergarden",
		name = "evergarden",
		priority = 1000,
		opts = {
			theme = {
				variant = "night", -- deep violet base
				accent = "rose", -- pinkish highlight accent
			},
			editor = {
				transparent_background = true, -- window background see-through
				float = { color = "surface0", solid_border = false },
			},
		},
		config = function(_, opts)
			require("evergarden").setup(opts)
			vim.cmd.colorscheme("evergarden")
		end,
	},
}
