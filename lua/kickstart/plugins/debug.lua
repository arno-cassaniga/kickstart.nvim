-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

-- This is a hashmap<string, number> of adapter names to PIDs, representing what is the current process
-- that we're willing to debug (using attach) for the specified provider
local DEBUGEES = {}

local ADAPTER_CORECLR = "coreclr"

local function patch_mason_nvim_dap_coreclr_launch(config)
  -- https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/configurations.lua
  local problematic_config = vim.tbl_filter(function(it)
    return it.name == "NetCoreDbg: Launch"
  end, config.configurations)[1]

  if not problematic_config then
    error("where is the problematic config?")
  end

  problematic_config.cwd = "${workspaceFolder}"
  problematic_config.program = function()
    local p = vim.fn.input({ prompt = "DLL:", completion = "file" })
    if not p or string.len(p) < 1 then
      error("nevermind then...")
    end
    return p
  end
end

local function query_running_processes_linux()
  local results = {}

  local ignore_these = { "-zsh", "/bin/zsh", "nvim", "/usr/lib/", "/usr/bin/", "tmux", "(sd-pam)", "/usr/share/zsh-theme" }
  local function starts_with(str, start)
    return str:sub(1, #start) == start
  end

  local lines = vim.fn.systemlist("ps -u $USER -o pid,cmd")
  for _, line in pairs(lines) do
    local start, _, c_pid, c_proc = string.find(line, "^%s*(%d+)%s+(.+)")
    if not start then
      goto continue
    end

    for _, ignore in pairs(ignore_these) do
      if starts_with(c_proc, ignore) then
        goto continue
      end
    end

    local entry = { tonumber(c_pid), c_proc }
    table.insert(results, entry)

    ::continue::
  end
  return results
end

local function show_telescope_process_picker(process_list, on_pid_selected)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  local telescope_opts = {}
  pickers.new(telescope_opts, {
    prompt_title = "pick process to debug",
    finder = finders.new_table {
      results = process_list,
      entry_maker = function(entry)
        return {
          value = entry,
          display = string.format("[%d] %s", entry[1], entry[2]),
          ordinal = entry[2],
        }
      end
    },
    sorter = conf.generic_sorter(telescope_opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)

        local selection = action_state.get_selected_entry()
        vim.print(vim.inspect(selection.value))
        vim.print(vim.inspect(selection.value[1]))
        on_pid_selected(selection.value[1])
      end)

      return true
    end
  }):find()
end

local function add_coreclr_attach_to_process_debug_config(config)
  table.insert(config.configurations, {
    type = ADAPTER_CORECLR,
    name = "CoreClr Attach to Process",
    request = "attach",
    processId = function()
      local selected_pid = DEBUGEES[ADAPTER_CORECLR]
      if not selected_pid then
        error("No debugee selected, please pick a process first.")
      end

      return selected_pid
    end
  });
end

local function pick_process_to_debug()
  vim.ui.select(
    { ADAPTER_CORECLR },
    { prompt_title = "select the debug adapter:" },
    function(adapter_type)
      if adapter_type then
        local processes = query_running_processes_linux()
        show_telescope_process_picker(processes, function(selected_pid)
          DEBUGEES[adapter_type] = selected_pid
        end)
      end
    end
  )
end

local function map_custom_user_commands()
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
    "DapPickDebugee",
    pick_process_to_debug,
    { desc = "Seleciona processo para debugar" }
  )
end

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',

    -- por causa das gambis que adicionei nesse arquivo
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,
      automatic_installation = false,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {
        coreclr = function(config)
          patch_mason_nvim_dap_coreclr_launch(config)
          add_coreclr_attach_to_process_debug_config(config)

          require('mason-nvim-dap').default_setup(config)
        end
      },

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'netcoredbg',
        'codelldb'
      },
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F1>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F2>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<S-F2>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    map_custom_user_commands()

    -- Install golang specific config
    require('dap-go').setup()
  end,
}

-- vim: ts=2 sts=2 sw=2 et
