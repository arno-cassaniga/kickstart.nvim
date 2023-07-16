-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
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
	-- some colorschemes
	{
		"rose-pine/neovim", name = "rose-pine"
	},
	{
		"rebelot/kanagawa.nvim"
	},
	{
		"folke/tokyonight.nvim"
	},
	{
		"Mofiqul/dracula.nvim"
	},
	-- vamo ver se a hype ajuda
	{
		"ThePrimeagen/harpoon"
	},
	-- vamo ver se a hype ajuda
	{
		"jiangmiao/auto-pairs"
	}
}

