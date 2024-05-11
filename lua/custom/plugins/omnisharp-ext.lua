return {
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    ft = "cs",
    config = function()
      vim.keymap.set('n', 'god', function()
        require('omnisharp_extended').telescope_lsp_definition({ jump_type = "vsplit" })
      end, { desc = '[G]oto defs [O]mnisharp: [D]efinition' })

      vim.keymap.set('n', 'gor', function()
        require('omnisharp_extended').telescope_lsp_references()
      end, { desc = '[G]oto defs [O]mnisharp: [R]eferences' })

      vim.keymap.set('n', 'goD', function()
        require('omnisharp_extended').telescope_lsp_type_definition()
      end, { desc = '[G]oto defs [O]mnisharp: Type [D]efinition' })

      vim.keymap.set('n', 'goi', function()
        require('omnisharp_extended').telescope_lsp_implementation()
      end, { desc = '[G]oto defs [O]mnisharp: [I]mplementation' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
