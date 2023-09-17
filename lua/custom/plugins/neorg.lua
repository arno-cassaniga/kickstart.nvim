return {
	{
		"nvim-neorg/neorg",
		build = ":Neorg sync-parsers",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("neorg").setup {
				load = {
					["core.defaults"] = {}, -- Loads default behaviour
          ["core.summary"] = {},
          ["core.concealer"] = {
            config = {
              icon_preset = "diamond"
            }
          }, -- Adds pretty icons to your documents
					["core.dirman"] = { -- Manages Neorg workspaces
						config = {
							workspaces = {
								general = "~/neorg/general",
							},
              default_workspace = "general"
						},
					},
				},
			}
		end,
	},
}
-- vim: ts=2 sts=2 sw=2 et
