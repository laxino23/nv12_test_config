---@param names table
local function use(names)
  for _, name in ipairs(names) do
    require("plugins." .. name)
  end
end

use({
  "treesitter",
  "themes",
  "blink",
  "extras",
  "lsp",
  "snacks",
  "indent",
  "heirline",
  "overseer",
  "noice",
  "folding",
  "todos",
})
