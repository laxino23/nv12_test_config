local M = {}

-- =============================================================================
-- Keymap Utility / 按键映射工具
-- =============================================================================

---Batch register key mappings from a configuration table.
---批量注册配置表中的按键映射。
---@param config table<string, table>
---@param opts table|nil
M.map = function(config, opts)
  opts = opts or {}

  for name, map_def in pairs(config) do
    -- Replace hyphens with spaces for description
    local desc = name:gsub("-", " ")
    local mode = map_def[1]
    local lhs = map_def[2]
    local rhs = map_def[3]

    local specific_opts = {}
    for k, v in pairs(map_def) do
      if type(k) ~= "number" then
        specific_opts[k] = v
      end
    end

    local final_opts = vim.tbl_deep_extend("force", opts, specific_opts, { desc = desc })
    vim.keymap.set(mode, lhs, rhs, final_opts)
  end
end

-- =============================================================================
-- Load Modules / 加载模块
-- =============================================================================
-- Inject the map function into sub-modules
-- 将 map 函数注入子模块

require("config.keymaps.movement")(M.map)
require("config.keymaps.comment")(M.map)
require("config.keymaps.text_case")(M.map)
require("config.keymaps.editor")(M.map)
require("config.keymaps.navigation")(M.map)
require("config.keymaps.terminal")(M.map)

return M
