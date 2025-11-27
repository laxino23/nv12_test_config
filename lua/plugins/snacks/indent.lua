return {
  {
    "folke/snacks.nvim",
    opts = {
      -- 缩进模块的主配置
      indent = {
        -- 如果要启用下面的功能，必须把这里改为 true。
        enabled = false,

        -- === 1. 基础缩进线 (Basic Indent Guides) ===
        indent = {
          enabled = true,
          only_current = true, -- 只显示当前光标相关的缩进线（减少视觉杂乱）
          only_scope = true, -- 仅在有作用域的地方显示
          -- char = "⋮",
          char = "", -- 缩进线使用的字符（这里选用了比较细的虚线）
          -- char = "┊",

          -- 彩虹缩进色 (Rainbow Indent):
          -- 定义了一组颜色，随着缩进层级的加深，循环使用这些颜色。
          -- (需要在你的配色方案中支持这些高亮组，或者 Snacks 会自动生成)
          hl = {
            "SnacksIndentRed",
            "SnacksIndentYellow",
            "SnacksIndentBlue",
            "SnacksIndentOrange",
            "SnacksIndentGreen",
            "SnacksIndentViolet",
            "SnacksIndentCyan",
          },
        },

        -- === 2. 作用域高亮 (Scope) ===
        -- 指示当前光标具体处于哪一个代码块（例如哪个 if 或 function 内部）
        scope = {
          enabled = false, -- [!] 子开关：关闭
          char = "║", -- 当前作用域使用“双竖线”，比普通缩进线更粗、更显眼
          -- char = "┊",
          underline = true, -- 在作用域的起始行（例如 function 那一行）显示下划线
          only_current = true, -- 只显示当前作用域

          -- 作用域也使用了彩虹色配置
          hl = {
            "SnacksIndentScopeRed",
            "SnacksIndentScopeYellow",
            "SnacksIndentScopeBlue",
            "SnacksIndentScopeOrange",
            "SnacksIndentScopeGreen",
            "SnacksIndentScopeViolet",
            "SnacksIndentScopeCyan",
          },
        },

        -- === 3. 代码块/区块 (Chunk) ===
        -- 这通常用于在作用域的顶部和底部画出“拐角”，形成一个半包围的框
        chunk = {
          enabled = true, -- [!] 子开关：关闭

          -- 定义拐角的字符，这里使用的是圆角风格
          char = {
            -- corner_top = "┌",
            -- corner_bottom = "└",
            corner_top = "╭", -- 上拐角
            corner_bottom = "╰", -- 下拐角
            horizontal = "─", -- 水平线
            vertical = "│", -- 垂直线
            arrow = "", -- 箭头符号
          },
          only_current = true,

          -- 代码块的高亮颜色配置
          hl = {
            "SnacksIndentChunkRed",
            "SnacksIndentChunkYellow",
            "SnacksIndentChunkBlue",
            "SnacksIndentChunkOrange",
            "SnacksIndentChunkGreen",
            "SnacksIndentChunkViolet",
            "SnacksIndentChunkCyan",
          },
        },
      },
    },
  },
}
