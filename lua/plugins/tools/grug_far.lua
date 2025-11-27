return {
  "MagicDuck/grug-far.nvim",
  -- headerMaxWidth: 设置顶部设置栏的最大宽度
  opts = { headerMaxWidth = 80 },
  cmd = "GrugFar",
  keys = {
    -- 快捷键: <leader>sr (在 Normal 或 Visual 模式下)
    -- 作用: 打开搜索窗口，但会自动填入当前文件的后缀名作为过滤器。
    --       例如：你在 main.lua 里按这个键，它会自动限制只搜索 *.lua 文件。
    --       这可以防止你误修改了 .txt 或 .json 等无关文件。
    {
      "<leader>sr",
      function()
        local grug = require("grug-far")
        -- 获取当前文件的扩展名 (例如 "lua", "py", "rs")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          -- transient: true 表示这是一个临时窗口，关闭后不会留在 buffer 列表中
          transient = true,
          prefills = {
            -- 如果获取到了扩展名，就填入 filesFilter (例如 "*.lua")
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end,
      mode = { "n", "v" },
      desc = "Search and Replace (当前文件类型)",
    },
  },
}
