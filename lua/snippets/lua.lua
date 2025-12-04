local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- 辅助函数：f 的依赖项必须是 table
local function github_url(node_indx)
  return f(function(args)
    local text = args[1][1]
    if text == "" then
      return "https://github.com/"
    end
    return "https://github.com/" .. vim.trim(text) .. ".git"
  end, { node_indx })
end

-- 辅助函数：大驼峰转化 (my-plugin -> MyPlugin)
local function to_pascal_case(node_indx)
  return f(function(args)
    local text = args[1][1] or ""
    if text == "" then
      return ""
    end
    -- 移除 .lua 等后缀
    text = text:gsub("%.lua$", "")
    -- 替换分隔符为大驼峰
    return text:gsub("[-._](%l)", string.upper):gsub("^%l", string.upper)
  end, { node_indx })
end

-- 辅助函数：提取最后一个单词 (plugin/telescope -> telescope)
-- local function get_module_name(node_indx)
--   return f(function(args)
--     local text = args[1][1] or ""
--     local parts = vim.split(text, "/", { plain = true })
--     return parts[#parts] or text
--   end, { node_indx })
-- end

return {
  -- 1. vim.pack.add 大块
  -- 🟢 修复：现在有两个 {} 占位符，对应 i(1) 和 i(0)
  s(
    "pack",
    fmt(
      [[vim.pack.add({{
  {{ src = "{}" }},
  {}
}})]],
      {
        i(1, "author/repo"),
        i(0),
      }
    )
  ),

  -- 2. 单行插件
  s("pl", fmt([[{{ src = "{}" }},]], { github_url(1), i(1, "author/repo") })),

  -- 3. 快捷键映射
  s(
    "map",
    fmt([[vim.keymap.set("{}","{}","{}",{{ desc = "{}" }})]], {
      i(1, "n"),
      i(2, "<leader>xx"),
      i(3, "<cmd>echo 'hello'<cr>"),
      i(4, "描述"),
    })
  ),

  -- 4. 自动命令
  s(
    "auto",
    fmt(
      [[vim.api.nvim_create_autocmd("{}", {{
  group = vim.api.nvim_create_augroup("{}", {{ clear = true }}),
  pattern = "{}",
  callback = function()
    {}
  end,
}})]],
      { i(1, "FileType"), i(2, "MyGroup"), i(3, "*"), i(0) }
    )
  ),

  -- 5. 自定义命令
  s(
    "cmd",
    fmt(
      [[vim.api.nvim_create_user_command("{}", function(opts)
  {}
end, {{ desc = "{}" }})]],
      { i(1, "MyCmd"), i(0), i(2, "命令描述") }
    )
  ),

  -- 6. 安全 require
  -- 🟢 优化：输入 module 名，自动生成变量名
  -- 逻辑：local {2:变量名} = pcall(require, "{1:模块名}")
  s(
    "req",
    fmt(
      [[local ok, {} = pcall(require, "{}")
if ok then
  {}.setup({{
    {}
  }})
end]],
      {
        to_pascal_case(1), -- 1. 自动生成的变量名 (放在第一个占位符)
        i(1, "mod"), -- 2. 这里的 i(1) 对应第二个占位符 (模块名)
        to_pascal_case(1), -- 3. 再次使用变量名
        i(0),
      }
    )
  ),

  -- 7. 打印调试
  s("pp", fmt([[print(vim.inspect({}))]], { i(1, "variable") })),

  -- 8. vim.opt 设置
  s("opt", fmt([[vim.opt.{} = {}]], { i(1, "shiftwidth"), i(2, "2") })),

  -- 9. vim.opt 追加
  s("opt+", fmt([[vim.opt.{}:append("{}")]], { i(1, "path"), i(2, "**") })),

  -- 10. 全局变量
  s("g", fmt([[vim.g.{} = {}]], { i(1, "mapleader"), i(2, '" "') })),

  -- 11. 窗口局部
  s("wo", fmt([[vim.wo.{} = {}]], { i(1, "number"), i(2, "true") })),

  -- 12. Buffer 局部
  s("bo", fmt([[vim.bo.{} = {}]], { i(1, "shiftwidth"), i(2, "2") })),

  -- 13. Lazy.nvim 规格
  s(
    "lazy",
    fmt(
      [[{{
  "{}",
  event = {{ "{}" }},
  config = function()
    {}
  end,
}},]],
      { i(1, "author/repo"), i(2, "VeryLazy"), i(0) }
    )
  ),

  -- 14. WhichKey
  s(
    "wk",
    fmt(
      [[require("which-key").register({{
  [{}] = {{ "{}", "{}" }},
}}, {{ prefix = "<leader>" }})]],
      { i(1, '"f"'), i(2, "<cmd>Telescope find_files<cr>"), i(3, "Find files") }
    )
  ),

  -- 15. 高亮
  s(
    "hi",
    fmt([[vim.api.nvim_set_hl(0, "{}", {{ fg = "{}", bg = "{}", {} }})]], {
      i(1, "MyHighlight"),
      i(2, "#ff8800"),
      i(3, "none"),
      i(4, "bold = true"),
    })
  ),

  -- 16. ipairs
  s(
    "fori",
    fmt(
      [[for {}, {} in ipairs({}) do
  {}
end]],
      { i(1, "_"), i(2, "v"), i(3, "tbl"), i(0) }
    )
  ),

  -- 17. pairs
  s(
    "forp",
    fmt(
      [[for {}, {} in pairs({}) do
  {}
end]],
      { i(1, "k"), i(2, "v"), i(3, "tbl"), i(0) }
    )
  ),

  -- 18. Todo
  s(
    "todo",
    fmt([[-- {} {}: {}]], {
      f(function()
        return os.date("%Y-%m-%d")
      end),
      i(1, "TODO"),
      i(0, "内容"),
    })
  ),

  -- 19. LazySet
  s(
    "lazyset",
    fmt(
      [[vim.keymap.set("{}", "{}", function()
  require("{}").{}()
end, {{ desc = "{}" }})]],
      {
        i(1, "n"),
        i(2, "<leader>ff"),
        i(3, "telescope.builtin"),
        i(4, "find_files"),
        i(5, "Find files"),
      }
    )
  ),

  -- 20. Local Require (修复逻辑：输入 require 路径 -> 生成变量名)
  -- 🟢 优化：fmt 占位符顺序调整，先显示变量名(自动)，再显示 require(输入)
  s(
    "lr",
    fmt([[local {} = require("{}")]], {
      to_pascal_case(1), -- 1. 对应第一个 {} (自动生成变量名)
      i(1, "mymod"), -- 2. 对应第二个 {} (输入模块名)
    })
  ),

  -- 21. Sign
  s(
    "sign",
    fmt([[vim.fn.sign_define("{}", {{ text = "{}", texthl = "{}", numhl = "{}" }})]], {
      i(1, "DiagnosticSignError"),
      i(2, ""),
      i(3, "DiagnosticSignError"),
      i(4, ""),
    })
  ),

  -- 22. Augroup
  s(
    "aug",
    fmt([[local {} = vim.api.nvim_create_augroup("{}", {{ clear = true }})]], {
      i(1, "augroup"),
      i(2, "MyGroup"),
    })
  ),

  -- 23. Function
  s(
    "fn",
    fmt(
      [[local function {}({})
  {}
end]],
      { i(1, "name"), i(2), i(0) }
    )
  ),

  -- 24. Module Template
  s(
    "mod",
    t({
      "local M = {}",
      "",
      "function M.setup(opts)",
      "  vim.validate { opts = { opts, 'table', true } }",
      "end",
      "",
      "return M",
    })
  ),

  -- 25. File Path
  s(
    "file",
    f(function()
      local full = vim.fn.expand("%:p")
      local cwd = vim.loop.cwd() .. "/"
      if full:sub(1, #cwd) == cwd then
        return "-- " .. full:sub(#cwd + 1)
      else
        return "-- " .. full
      end
    end)
  ),
}
