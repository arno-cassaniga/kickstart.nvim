return {
  -- some colorschemes
  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
  },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000,
  },
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
  },
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    opts = {
      transparent = true,
    },
    init = function()
      vim.cmd.colorscheme 'tokyonight-moon'
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'Mofiqul/dracula.nvim',
    priority = 1000,
  },
}
