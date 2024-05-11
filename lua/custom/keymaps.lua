local M = {}

local function keymaps_diagnostics()
  vim.keymap.set('n', '[d', function()
    vim.diagnostic.goto_prev { severity = { min = vim.diagnostic.severity.INFO } }
  end, { desc = 'Go to previous [D]iagnostic message' })

  vim.keymap.set('n', ']d', function()
    vim.diagnostic.goto_next { severity = { min = vim.diagnostic.severity.INFO } }
  end, { desc = 'Go to next [D]iagnostic message' })

  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
  vim.keymap.set('n', '<leader>E', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
end

local function keymaps_harpoon()
    vim.keymap.set({ 'n' }, '<C-h>a', function() require("harpoon.mark").add_file() end, { desc = '[H]arpoon [A]dd file' })
    vim.keymap.set({ 'n' }, '<C-h>h', function() require("harpoon.ui").toggle_quick_menu() end, { desc = '[H]arpoon Open' })
    vim.keymap.set({ 'n' }, '<C-h>j', function() require("harpoon.ui").nav_file(1) end, { desc = '[H]arpoon: Nav 1' })
    vim.keymap.set({ 'n' }, '<C-h>k', function() require("harpoon.ui").nav_file(2) end, { desc = '[H]arpoon: Nav 2' })
    vim.keymap.set({ 'n' }, '<C-h>l', function() require("harpoon.ui").nav_file(3) end, { desc = '[H]arpoon: Nav 3' })
    vim.keymap.set({ 'n' }, '<C-h>;', function() require("harpoon.ui").nav_file(4) end, { desc = '[H]arpoon: Nav 4' })
    vim.keymap.set({ 'n' }, '<C-h>n', function() require("harpoon.ui").nav_next() end, { desc = '[H]arpoon: [N]ext' })
    vim.keymap.set({ 'n' }, '<C-h>p', function() require("harpoon.ui").nav_prev() end, { desc = '[H]arpoon: [P]revious' })
end

local function keymaps_yank_paste_utils()
    vim.keymap.set({ 'n' }, '<leader>py', '<Cmd>let @+ = expand("%:t")<cr>', { desc = '[P]ath [y]anking to clipboard' })
    vim.keymap.set({ 'n' }, '<leader>pY', '<Cmd>let @+ = expand("%")<cr>', { desc = '[P]ath [Y]anking (full) to clipboard' })

    vim.keymap.set({ 'n' }, 'gp', '`[v`]', { desc = '[G]o to last [P]asted text in visual mode' })
end

local function keymaps_persistence()
    vim.keymap.set({ 'n' }, '<leader>qq', function() require("persistence").load() end, { desc = 'Restore nvim session for current directory' })
    vim.keymap.set({ 'n' }, '<leader>ql', function() require("persistence").load({ last = true }) end, { desc = 'Restore last nvim session' })
    vim.keymap.set({ 'n' }, '<leader>qd', function() require("persistence").stop() end, { desc = 'Disable session persistence on exit' })
end

local function keymaps_tree()
    vim.keymap.set({ 'n' }, '<leader>tt', '<Cmd>NvimTreeFindFileToggle<cr>', { desc = '[T]oggles Nvim[T]ree focusing the file' })
    vim.keymap.set({ 'n' }, '<leader>to', '<Cmd>NvimTreeToggle<cr>', { desc = 'Toggles Nvim[T]ree but only [O]pens it' })
end

local function keymaps_dap()
  local _dap = nil
  local function dap()
    if not _dap then
      _dap = require("dap")
    end
    return _dap
  end

  local _dapui = nil
  local function dapui()
    if not _dapui then
      _dapui = require("dapui")
    end
    return _dapui
  end

  -- Basic debugging keymaps, feel free to change to your liking!
  vim.keymap.set('n', '<F5>', function() dap().continue() end, { desc = 'Debug: Start/Continue' })
  vim.keymap.set('n', '<F1>', function() dap().step_over() end, { desc = 'Debug: Step Over' })
  vim.keymap.set('n', '<F2>', function() dap().step_into() end, { desc = 'Debug: Step Into' })
  vim.keymap.set('n', '<S-F2>', function() dap().step_out() end, { desc = 'Debug: Step Out' })
  vim.keymap.set('n', '<leader>b', function() dap().toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
  vim.keymap.set('n', '<leader>B', function()
    dap().set_breakpoint(vim.fn.input 'Breakpoint condition: ')
  end, { desc = 'Debug: Set Breakpoint' })

  -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
  vim.keymap.set('n', '<F7>', function() dapui().toggle() end, { desc = 'Debug: See last session result.' })
end

local function user_cmds()

  vim.api.nvim_create_user_command(
    "SnippetsReload",
    function()
      vim.cmd.source("~/.config/nvim/after/plugin/luasnip.lua")
    end,
    { }
  )

  vim.api.nvim_create_user_command(
    "DapLoadLaunchJs",
    function()
      require("dap.ext.vscode").load_launchjs(nil, {
        coreclr = { "cs" }
      })
    end,
    { desc = "Esse eh o correto" }
  )

  vim.api.nvim_create_user_command(
    "DapBreakOnExceptions",
    function()
      require("dap").set_exception_breakpoints()
    end,
    { desc = "Bota quebrar em exceptions" }
  )

  vim.api.nvim_create_user_command(
    "BufferCleanup",
    "%bd | e# | bd #",
    { desc = "Perform cleanup on open buffers" }
  )
end

function M.setup()
  keymaps_diagnostics()
  keymaps_harpoon()
  keymaps_persistence()
  keymaps_yank_paste_utils()
  keymaps_tree()
  keymaps_dap()

  --misc
  vim.keymap.set({ 'v' }, '<leader>f', function() vim.lsp.buf.format() end, { desc = '[F]ormat the selection' })
  vim.keymap.set({ 'n' }, '<leader>l', function() vim.cmd.edit("~/.config/nvim/init.lua") end, { desc = 'Edit the [L]ua config file (nvim/init.lua)' })
  vim.keymap.set({ 'i' }, '<C-j>', '<C-[>', { desc = 'Exit INSERT mode' })

  user_cmds()
end

return M
-- vim: ts=2 sts=2 sw=2 et
