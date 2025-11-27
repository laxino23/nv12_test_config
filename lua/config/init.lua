---@param names table|string
function use(names)
  if type(names) == "table" then
    for _, name in ipairs(names) do
      require("config." .. name)
    end
  else
    require("config." .. names)
  end
end

use({
  "opts",
  "autocmds",
  "keymaps",
  "lazy",
})
