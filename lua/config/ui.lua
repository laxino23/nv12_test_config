local M = {}

-- ===========================================================================
-- 1. cmp_draw: 自定义 nvim-cmp (自动补全) 菜单的渲染外观
-- ===========================================================================
M.cmp_draw = {
  -- 针对 mini.nvim 图标库的渲染配置
  mini = {
    kind_icon = {
      text = function(ctx)
        -- 获取图标
        local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
        return kind_icon
      end,
      highlight = function(ctx)
        -- 获取高亮组
        local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
        return hl
      end,
    },
    kind = {
      text = function(ctx)
        return "[" .. ctx.kind .. "]"
      end, -- 显示文字，如 [Function]
      highlight = function(ctx)
        local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
        return hl
      end,
    },
  },

  -- 针对 lspkind 插件的渲染配置 (这也是目前较为主流的配置)
  lspkind = {
    kind_icon = {
      text = function(ctx)
        local icon = ctx.kind_icon
        -- 特殊处理：如果补全来源是 "Path" (文件路径)
        if vim.tbl_contains({ "Path" }, ctx.source_name) then
          -- 使用 nvim-web-devicons 获取具体文件的图标 (比如 .lua 文件显示 lua 图标，而不是通用的 File 图标)
          local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
          if dev_icon then
            icon = dev_icon
          end
        else
          -- 否则使用标准的 LSP 类型图标
          icon = require("lspkind").symbolic(ctx.kind, {
            mode = "symbol",
          })
        end
        return icon .. ctx.icon_gap
      end,
      highlight = function(ctx)
        local hl = ctx.kind_hl
        -- 同样为文件路径应用特定的文件类型颜色
        if vim.tbl_contains({ "Path" }, ctx.source_name) then
          local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
          if dev_icon then
            hl = dev_hl
          end
        end
        return hl
      end,
    },
    kind = {
      text = function(ctx)
        return "[" .. ctx.kind .. "]"
      end,
      highlight = function(ctx)
        -- 略... (逻辑同上)
        local hl = ctx.kind_hl
        if vim.tbl_contains({ "Path" }, ctx.source_name) then
          local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
          if dev_icon then
            hl = dev_hl
          end
        end
        return hl
      end,
    },
  },
}

-- ===========================================================================
-- 2. rainbow_colors: 彩虹颜色表 (通常用于彩虹括号或缩进线)
-- ===========================================================================
M.rainbow_colors = {
  red = "#E82424",
  orange = "#cc6d00",
  yellow = "#de9800",
  green = "#5e857a",
  cyan = "#4e8ca2",
  blue = "#4d699b",
  purple = "#957FB8",
}

-- ===========================================================================
-- 3. layout: Snacks Picker 的窗口布局预设
-- ===========================================================================
M.layout = {
  -- select: 类似 vim.ui.select 的小弹窗
  select = {
    preview = false, -- 不显示预览
    layout = {
      backdrop = false,
      row = 0.4,
      width = 0.7,
      min_width = 80,
      height = 0.4,
      min_height = 3,
      box = "vertical",
      border = "rounded",
      title = "{title}",
      title_pos = "center",
      { win = "input", height = 1, border = "bottom" }, -- 输入框在顶部
      { win = "list", border = "none" }, -- 列表在下
      { win = "preview", title = "{preview}", height = 0.4, border = "top" },
    },
  },

  -- dropdown: 标准下拉大弹窗 (居中)
  dropdown = {
    layout = {
      backdrop = false,
      row = -1,
      width = 0.85,
      min_width = 80,
      height = 0.9, -- 占据屏幕 90% 高度
      border = "none",
      box = "vertical",
      { win = "preview", title = "{preview}", height = 0.45, border = "rounded" }, -- 预览窗口在上
      {
        box = "vertical",
        border = "none",
        title = "{title} {live} {flags}",
        title_pos = "center",
        { win = "input", height = 1, border = "bottom" }, -- 输入框
        { win = "list", border = "none" }, -- 列表在最下
      },
    },
  },

  -- dropdown_pick: 紧凑型下拉 (用于快速文件切换，如你的 ff 快捷键)
  dropdown_pick = {
    layout = {
      backdrop = false,
      row = -1,
      width = 0.75,
      min_width = 80,
      height = 0.4, -- 只占 40% 高度
      border = "none",
      box = "vertical",
      -- 注意：这里注释掉了 preview，说明这个布局默认不看预览，只看列表
      {
        box = "vertical",
        border = "none",
        title = "{title} {live} {flags}",
        title_pos = "center",
        { win = "input", height = 1, border = "bottom" },
        { win = "list", border = "none" },
      },
    },
  },

  -- vscode: 模仿 VSCode 命令面板的风格
  vscode = {
    preview = false,
    layout = {
      backdrop = false,
      row = 0.4,
      width = 0.7,
      min_width = 80,
      height = 0.4,
      border = "none",
      box = "vertical",
      {
        win = "input",
        height = 1,
        border = "rounded", -- 只有输入框有圆角边框
        title = "{title} {live} {flags}",
        title_pos = "center",
      },
      { win = "list", border = "hpad" }, -- 列表有水平内边距
      { win = "preview", title = "{preview}", border = "rounded" },
    },
  },

  -- ivy: 底部面板风格 (类似 Emacs Ivy)
  ivy = {
    layout = {
      box = "vertical",
      backdrop = false,
      row = -1,
      width = 0,
      height = 0.35, -- 宽度 0 表示占满全宽，高度 35%
      border = "top", -- 只有顶部有边框
      title = " {title} {live} {flags}",
      title_pos = "left",
      { win = "input", height = 1, border = "bottom" },
      {
        box = "horizontal",
        { win = "list", border = "none" },
      },
    },
  },

  -- ivy_preview: 带预览的 Ivy 风格
  ivy_preview = {
    layout = {
      box = "vertical",
      backdrop = false,
      row = -1,
      width = 0,
      height = 0.45,
      border = "top",
      title = " {title} {live} {flags}",
      title_pos = "left",
      { win = "input", height = 1, border = "bottom" },
      {
        box = "horizontal",
        { win = "list", border = "none" },
        { win = "preview", title = "{preview}", width = 0.5, border = "left" }, -- 预览在右侧占 50%
      },
    },
  },

  -- ivy_border: <leader>/ (grep lines) 使用了这个布局
  ivy_border = {
    layout = {
      box = "horizontal",
      row = -1,
      width = 0,
      min_width = 120,
      height = 0.35,
      backdrop = false,
      {
        box = "vertical",
        border = "none",
        title = "{title} {live} {flags}",
        { win = "input", height = 1, border = "bottom" },
        { win = "list", border = false },
      },
      { win = "preview", title = "{preview}", border = "rounded", width = 0.45 },
    },
  },

  -- right: 右侧边栏风格 (你的 <leader>E 使用了这个)
  right = {
    preview = "main", -- 预览显示在主窗口
    layout = {
      backdrop = false,
      width = 40,
      min_width = 40,
      height = 0, -- 高度 0 表示占满全高
      position = "right",
      border = "none",
      box = "vertical",
      {
        win = "input",
        height = 1,
        border = true,
        title = "{title} {live} {flags}",
        title_pos = "center",
      },
      { win = "list", border = "none" },
      { win = "preview", title = "{preview}", height = 0.4, border = "top" },
    },
  },
}

-- ===========================================================================
-- 4. fzf: 针对 fzf-lua 插件的布局配置
-- ===========================================================================
M.fzf = {
  dropdown = {
    winopts = {
      height = 0.70,
      width = 0.80,
      row = 1,
      col = 0.50,
      border = "none",
      backdrop = 100,
      preview = { border = "rounded", wrap = true, layout = "vertical", vertical = "up:45%" },
    },
  },
}

-- ===========================================================================
-- 5. icons: 集中管理的图标库
--    这里定义了多套图标，方便在不同插件中复用
-- ===========================================================================
M.icons = {
  -- 默认 LSP 类型图标 (VSCode 风格)
  default_kind_icons = {
    Array = "",
    Boolean = "󰨙",
    Class = "",
    Function = "",
    Method = "",
  },

  -- 适配 Mini.nvim 的图标
  mini_kind_icons = {},

  -- 适配 Lazy.nvim 风格的图标
  lazy_kind_icons = {},

  -- 在 snacks.nvim 中引用的 ui.icons.lspkind_kind_icons
  lspkind_kind_icons = {
    String = " ",
    Object = " ",
    Array = " ",
    Boolean = "󰨙 ",
    Text = "󰉿",
    Number = "󰎠 ",
    Method = "󰊕",
    Function = "󰊕",
    Constructor = "",
    Field = "󰜢",
    Variable = "󰀫",
    Class = "󰠱",
    Snippet = "󱄽 ",
    File = "󰈙",
    Folder = "󰉋",
  },

  -- 杂项图标 (Git, 调试, 终端等)
  misc = {
    dots = "󰇘",
    bug = "",
    git = "",
    search = "",
    terminal = "",
  },

  -- 调试工具 (DAP) 图标
  dap = {
    Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" }, -- 调试暂停时的箭头
    Breakpoint = " ", -- 断点图标
  },

  -- 诊断信息 (Diagnostics) 图标 (错误, 警告等)
  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
  },

  -- Git 状态图标 (增加, 修改, 删除)
  git = {
    added = " ",
    modified = " ",
    removed = " ",
  },
}

return M
