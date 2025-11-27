return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    -- "rcarriga/nvim-notify", -- [建议] 配合 notify 获得漂亮的右上角通知动画
  },
  keys = {
    {
      "<leader>H",
      function()
        require("noice").cmd("history")
      end,
      desc = "Noice History (查看通知历史)",
    },
  },
  opts = {
    -- =========================================================
    -- LSP: 接管 LSP 的 UI (悬停文档、重命名等)
    -- =========================================================
    lsp = {
      override = {
        -- 覆盖 Neovim 默认的 LSP Markdown 渲染，让文档高亮更漂亮
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        -- 禁用 cmp 的文档弹窗，交给 noice 处理 (如果这是你想要的)
        ["cmp.entry.get_documentation"] = true,
      },
      hover = { enabled = true }, -- 开启悬停文档 (Shift+k) 的美化
      signature = { enabled = false },
    },

    -- =========================================================
    -- Routes: 路由规则 (决定消息显示在哪里)
    -- 作用: 过滤掉烦人的系统消息，防止它们占据屏幕中央
    -- =========================================================
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" }, -- 过滤 "100L, 200B" (写入文件时的提示)
            { find = "; after #%d+" }, -- 过滤 "Undo" 提示
            { find = "; before #%d+" }, -- 过滤 "Redo" 提示
            { find = "written" }, -- 过滤简单的 written 提示
          },
        },
        -- view = "mini", -- 以前是 mini，现在通常建议用 "notify" 或直接 "mini" 显示在右下角
        view = "mini",
      },
    },

    -- =========================================================
    -- Presets: 预设配置 (快速开启常见功能)
    -- =========================================================
    presets = {
      bottom_search = true, -- [偏好] 搜索栏 (/ 或 ?) 留在底部，不移动到屏幕中间

      -- 命令行面板配置 (输入 : 时的界面)
      command_palette = {
        views = {
          cmdline_popup = {
            position = {
              row = "65%", -- 把弹窗稍微往下放一点，不要挡住屏幕正中心的代码
              col = "50%",
            },
          },
        },
      },

      long_message_to_split = true, -- 如果消息太长（比如报错堆栈），自动分屏显示，而不是截断
      inc_rename = false, -- 如果你没装 inc-rename.nvim 插件，这里设为 false
      lsp_doc_border = true, -- 为 LSP 文档弹窗添加边框 (自动适配 rounded)
    },
  },

  -- =========================================================
  -- Config: 初始化逻辑
  -- =========================================================
  config = function(_, opts)
    -- HACK: 解决 Lazy 加载插件时产生的旧消息刷屏问题
    -- 如果当前是 lazy 的安装界面，先清空历史消息，保持清爽
    if vim.o.filetype == "lazy" then
      vim.cmd([[messages clear]])
    end
    require("noice").setup(opts)
  end,
}
