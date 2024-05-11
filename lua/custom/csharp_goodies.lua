local M = { }

-- csharp tooling can really be overly helpful with suggestions,
-- so let's tone down the signaling for all those diagnostics
local custom_csharp_diag_config = {
  signs = {
    severity = { min = vim.diagnostic.severity.INFO }
  },
  virtual_text = {
    severity = { min = vim.diagnostic.severity.INFO }
  },
  underline = {
    severity = { min = vim.diagnostic.severity.INFO }
  },
}

function M.lsp_handler_publish_diagnostics(err, result, ctx, config)
  if config then
    config = vim.tbl_deep_extend('force', config, custom_csharp_diag_config)
  else
    config = custom_csharp_diag_config
  end

  return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
end

M.lsp_handlers_overrides = {
  ["textDocument/publishDiagnostics"] = M.lsp_handler_publish_diagnostics
}

return M
-- vim: ts=2 sts=2 sw=2 et
