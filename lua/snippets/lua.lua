local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

ls.add_snippets("lua", {
  -- 1. 基本函数定义 (trig: fn)
  s(
    {
      trig = "fn",
      name = "Function Definition",
      dscr = "创建一个 Lua 函数，支持参数和返回",
    },
    fmt(
      [[
    local function {name}({args})
      {body}
    end
  ]],
      {
        name = i(1, "func_name"),
        args = i(2, ""),
        body = i(0),
      }
    )
  ),

  -- 2. require 导入语句 (trig: req)
  s(
    {
      trig = "req",
      name = "Require Module",
      dscr = "导入 Lua 模块，支持本地变量",
    },
    fmt(
      [[
    local {var} = require("{mod}")
    {next}
  ]],
      {
        mod = i(1, "module.name"),
        var = f(function(args)
          return args[1][1]:gsub("[%.%-]", "_")
        end, { 1 }), -- 动态生成变量名
        next = i(0),
      }
    )
  ),

  -- 3. Neovim 按键映射 (trig: keymap)
  s(
    {
      trig = "keymap",
      name = "Vim Keymap Set",
      dscr = "设置 Neovim 按键映射，支持模式选择",
    },
    fmt(
      [[
    vim.keymap.set("{mode}", "{lhs}", {rhs}, {{ {opts} }})
    {next}
  ]],
      {
        mode = c(1, { t("n"), t("i"), t("v"), t({ "n", "v" }), t("") }), -- 选择模式
        lhs = i(2, "<leader>xx"),
        rhs = i(3, "function() end"),
        opts = i(4, "noremap = true, silent = true"),
        next = i(0),
      }
    )
  ),

  -- 4. Neovim 选项设置 (trig: opt)
  s(
    {
      trig = "opt",
      name = "Vim Option Set",
      dscr = "设置 vim.o 或 vim.g 选项",
    },
    fmt(
      [[
    vim.{scope}.{opt} = {value}
    {next}
  ]],
      {
        scope = c(1, { t("o"), t("g"), t("wo"), t("bo") }), -- 选择作用域
        opt = i(2, "option_name"),
        value = i(3, "true"),
        next = i(0),
      }
    )
  ),

  -- 5. Neovim 自动命令 (trig: autocmd)
  s(
    {
      trig = "autocmd",
      name = "Autocmd Definition",
      dscr = "创建 Neovim 自动命令组和事件",
    },
    fmt(
      [[
    vim.api.nvim_create_augroup("{group}", {{ clear = true }})
    vim.api.nvim_create_autocmd("{event}", {{
      group = "{group_rep}",
      pattern = "{pat}",
      callback = function()
        {body}
      end,
    }})
    {next}
  ]],
      {
        group = i(1, "group_name"),
        group_rep = rep(1), -- 重复组名
        event = c(2, { t("BufEnter"), t("VimEnter"), t("FileType") }), -- 事件选择
        pat = i(3, "*"),
        body = i(4),
        next = i(0),
      }
    )
  ),

  -- 6. Lua 模块返回 (trig: modret)
  s(
    {
      trig = "modret",
      name = "Module Return",
      dscr = "返回一个 Lua 模块表，支持动态字段",
    },
    fmt(
      [[
    local M = {{}}

    {body}

    return M
  ]],
      {
        body = d(1, function()
          return sn(nil, {
            i(1, "-- add fields here"),
          })
        end, {}),
      }
    )
  ),

  -- 7. for 循环 (trig: for)
  s(
    {
      trig = "for",
      name = "For Loop",
      dscr = "Lua for 循环，支持 ipairs 或数字范围",
    },
    fmt(
      [[
    for {var} in {iter}({tbl}) do
      {body}
    end
  ]],
      {
        iter = c(1, { t("ipairs"), t("pairs") }),
        tbl = i(2, "table_name"),
        var = i(3, "k, v"),
        body = i(0),
      }
    )
  ),

  -- 8. if 语句 (trig: if)
  s(
    {
      trig = "if",
      name = "If Statement",
      dscr = "带 else 的 if 语句",
    },
    fmt(
      [[
    if {cond} then
      {then}
    else
      {else}
    end
  ]],
      {
        cond = i(1, "condition"),
        ["then"] = i(2), -- 添加方括号和引号
        ["else"] = i(0), -- 添加方括号和引号
      }
    )
  ),

  -- 9. 添加 GitHub 插件 (trig: ghadd)
  s(
    {
      trig = "ghadd",
      name = "Add GitHub Plugin",
      dscr = "添加单个 GitHub 插件，固定 https://github.com/ 前缀",
    },
    fmt(
      [[
    vim.pack.add({{
      {{ src = "https://github.com/{repo}"{opts} }}
    }}{load})
    {next}
  ]],
      {
        repo = i(1, "user/plugin"),
        opts = i(2, ", version = 'main'"),
        load = c(3, { t(""), t(", { load = true }") }),
        next = i(0),
      }
    )
  ),

  -- 10. require 和 setup (trig: reqsetup)
  s(
    {
      trig = "reqsetup",
      name = "Require and Setup Plugin",
      dscr = "加载插件并调用 setup 配置",
    },
    fmt(
      [[
    local {var} = require("{mod}")
    {var_rep}.setup({{
      {config}
    }})
    {next}
  ]],
      {
        mod = i(1, "plugin.name"),
        var = f(function(args)
          return args[1][1]:gsub("[%.%-]", "_")
        end, { 1 }), -- 动态生成变量名
        var_rep = rep(2), -- 重复变量名（注意：rep(2) 对应 var 的位置）
        config = i(3, "-- 配置选项"),
        next = i(0),
      }
    )
  ),
})
