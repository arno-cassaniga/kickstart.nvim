-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
	{
		"folke/persistence.nvim",
		event = "BufReadPre", -- this will only start session saving when an actual file was opened
		config = function()
			require("persistence").setup();
		end
	},
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup {}
		end,
	},
	{ "ThePrimeagen/harpoon" },
	{ "jiangmiao/auto-pairs" },
	-- some colorschemes
	{
		-- Theme inspired by Atom
		'navarasu/onedark.nvim',
		priority = 1000,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		priority = 1000,
	},
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
	},
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = {
			transparent = true
		}
	},
	{
		"Mofiqul/dracula.nvim",
		priority = 1000,
	},
}
