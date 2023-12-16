local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
-- local i = ls.insert_node
local f = ls.function_node

local path = require("plenary.path")
local scan = require("plenary.scandir")

local function suggest_namespace()
  local curr_file = path:new(vim.fn.expand("%:p"))
  local parents = curr_file:parents()

  local ns_parts = {}
  for _, filename in ipairs(parents) do
    local short_name = table.remove(
      vim.split(filename, curr_file.path.sep, { plain = true, trimempty = true })
    )
    table.insert(ns_parts, 1, short_name)

    local found_proj_files = scan.scan_dir(filename, { add_dirs = false, depth = 1, search_pattern = "%.csproj$" })
    if found_proj_files and #found_proj_files > 0 then
      return table.concat(ns_parts, '.')
    end
  end
  return "???"
end

ls.add_snippets(
  "cs",
  {
    s(
      { trig = "ns", name = "ns", desc = "snippet for adding namespace to csharp file" },
      {
        t("namespace "),
        f(suggest_namespace),
        t(";")
      }
    )
  },
  { key = "arno:csharp" }
)

-- vim: ts=2 sts=2 sw=2 et
