-- 引入外部的 UI 配置文件，用于统一管理布局和图标
local ui = require("config.ui")

return {
  "folke/snacks.nvim",
  opts = {
    -- === Picker (查找器) 核心配置 ===
    picker = {
      enabled = true, -- 启用 Picker 模块
      prompt = "> ", -- 搜索框提示符
      ui_select = true, -- 接管 vim.ui.select (例如代码修复 Code Actions 的选择弹窗)

      -- 默认布局设置
      layout = {
        cycle = true, -- 列表到底部时循环回到顶部
        layout = ui.layout.dropdown.layout, -- 使用 "下拉式 (dropdown)" 布局
      },

      -- 匹配算法设置
      matcher = {
        cwd_bonus = true, -- 优先显示当前目录下的文件
        frecency = true, -- 启用 "频率+最近使用" 算法 (Frequency + Recency)，常用的文件排前面
        history_bonus = true, -- 历史记录加权
      },

      -- 格式化显示设置
      formatters = {
        file = {
          filename_first = true, -- 搜索结果先显示文件名，再显示路径 (方便快速识别)
          truncate = 60, -- 路径过长时截断
        },
        severity = {
          icons = true, -- 显示诊断图标 (错误/警告)
          level = true, -- 显示等级文字
          pos = "left", -- 图标在左侧
        },
      },

      -- 窗口内的快捷键设置
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "n", "i" } }, -- 输入模式下按 Esc 直接关闭窗口
          },
        },
        list = {
          keys = {
            -- 列表导航快捷键 (类似 Vim 习惯)
            ["<c-j>"] = "list_down", -- 向下移动
            ["<c-k>"] = "list_up", -- 向上移动
            ["<c-n>"] = "list_down", -- (备用) 向下
            ["<c-p>"] = "list_up", -- (备用) 向上
          },
        },
      },

      -- 图标设置 (引用自 config.ui)
      icons = { kinds = ui.icons.lspkind_kind_icons },

      -- 自定义动作
      -- actions = {
      --   -- Sidekick 是一个 AI 辅助工具，这里定义了将搜索结果发送给 Sidekick 的动作
      --   sidekick_send = function(...)
      --     return require("sidekick.cli.snacks").send(...)
      --   end,
      -- },
    },
  },

  -- === 快捷键映射 ===
  keys = {
    -- 1. 文件资源管理器 (Explorer)
    {
      "<leader>ee",
      function()
        Snacks.explorer({ layout = ui.layout.right }) -- 在右侧打开文件树
      end,
      desc = "Snacks explorer", -- 描述：Snacks 资源管理器
    },

    -- 2. 命令面板
    {
      "<leader>:",
      function()
        Snacks.picker.commands() -- 搜索 Vim 命令 (类似 :Telescope commands)
      end,
      desc = "Snacks commands",
    },

    -- 3. 当前文件行搜索
    {
      "<leader>/",
      function()
        Snacks.picker.lines({ layout = ui.layout.ivy_border }) -- 使用 Ivy 布局 (底部面板) 搜索当前文件的内容
      end,
      desc = "Snacks lines",
      silent = true,
    },

    -- 4. 书签 (Marks)
    {
      "<leader>m",
      function()
        Snacks.picker.marks() -- 搜索 Vim 的书签 ('a-'z)
      end,
      desc = "Snacks marks",
      silent = true,
    },

    -- 5. 智能文件查找 (Smart Find) - 高频按键 ff
    {
      "ff",
      function()
        Snacks.picker.smart({
          hidden = true, -- 搜索包含隐藏文件 (.gitignore 除外)
          filter = { cwd = true }, -- 限制在当前工作目录
          preview = function()
            return false -- 关闭预览窗口 (追求极速，类似 VSCode 的 Ctrl+P)
          end,
          layout = ui.layout.dropdown_pick, -- 使用紧凑的下拉布局
        })
      end,
      desc = "Snacks smart",
      silent = true,
    },

    -- 6. 缓冲区切换 (Buffers) - 高频按键 nn
    {
      "nn",
      function()
        Snacks.picker.buffers({
          sort_lastused = true, -- 按最近使用排序
          current = false, -- 列表中不显示当前正在编辑的文件 (因为没必要切到自己)
          layout = ui.layout.dropdown_pick,
        })
      end,
      desc = "Snacks buffers",
      silent = true,
    },

    -- 7. 恢复上次搜索
    {
      "<leader>r",
      function()
        Snacks.picker.resume() -- 重新打开上一次关闭的搜索窗口
      end,
      desc = "Snacks resume",
    },

    -- === 搜索与 Grep ===

    -- 8. 搜索光标下的词 (整个项目)
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word({
          filter = { cwd = true }, -- 在当前工作目录搜索
        })
      end,
      desc = "Snacks search word under cursor",
      mode = { "n", "x", "v" }, -- 支持正常模式和可视模式
    },

    -- 9. 搜索光标下的词 (仅当前文件)
    {
      "<leader>sW", -- 注意是大写 W
      function()
        Snacks.picker.grep_word({
          filter = { cwd = true },
          buffers = true, -- 仅限已打开的 buffer
          dirs = { vim.fn.expand("%:p") }, -- 强制限定为当前文件路径
        })
      end,
      desc = "Snacks search word under cursor (current buffer)",
      mode = { "n", "x", "v" },
    },

    -- 10. 实时全局搜索 (Live Grep)
    {
      "<leader>sg",
      function()
        Snacks.picker.grep({
          filter = { cwd = true },
        })
      end,
      desc = "Snacks live grep",
    },
    {
      "<leader>sG", -- 大写 G，可能是用于忽略 .gitignore 的全局搜索，或者是默认 grep
      function()
        Snacks.picker.grep()
      end,
      desc = "Snacks live grep",
    },

    -- === 其他工具 ===

    -- 11. 禅模式 (Zen Mode)
    {
      "<leader>z",
      function()
        Snacks.zen()
      end,
      desc = "Toggle Zen Mode",
    },

    -- 12. 通知管理
    {
      "<leader>un",
      function()
        Snacks.notifier.hide() -- 关闭所有弹出的通知
      end,
      desc = "Dismiss All Notifications",
    },
    {
      "<leader>N",
      function()
        Snacks.picker.notifications() -- 查看通知历史记录
      end,
      desc = "Notifications",
    },

    -- 13. Quickfix 和 Loclist
    {
      "<leader>fq",
      function()
        Snacks.picker.qflist() -- 搜索 Quickfix 列表
      end,
      desc = "Snacks quickfix",
    },
    {
      "<leader>fl",
      function()
        Snacks.picker.loclist() -- 搜索 Location 列表
      end,
      desc = "Snacks loclist",
    },

    -- 14. TODO 注释搜索
    {
      "<leader>xt",
      function()
        ---@diagnostic disable-next-line: undefined-field
        Snacks.picker.todo_comments({
          keywords = { "TODO", "FIX", "FIXME", "NOTE", "PERF", "HACK" }, -- 搜索这些关键字
        })
      end,
      desc = "Todo/Fix/Fixme etc",
    },
  },
}
