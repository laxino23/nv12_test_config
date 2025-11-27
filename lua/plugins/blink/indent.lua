return {
  "saghen/blink.indent",
  event = "VeryLazy", -- 延迟加载，不拖慢启动速度
  opts = {
    -- === 屏蔽列表 (Blacklist) ===
    -- 在以下情况不显示缩进线，防止界面混乱
    blocked = {
      -- 包含默认的屏蔽项 (如 terminal, quickfix, nofile, prompt)
      buftypes = { include_defaults = true },
      
      -- 包含默认的文件类型，并额外添加了 Snacks Picker、Mason、Lazy 等弹窗插件
      -- 这样在打开这些浮动窗口时，背景里不会有奇怪的缩进线干扰视线
      filetypes = {
        include_defaults = true,
        "snacks_picker_input",
        "snacks_picker_list",
        "snacks_picker_preview",
        "snacks_terminal",
        "mason",
        "lazy",
        "fzf",
        "oil", 
      },
    },

    -- === 1. 静态缩进线 (Static) ===
    -- 指的是代码中所有层级的灰色竖线
    static = {
      enabled = false, -- [!] 重点：这里设置为关闭。意味着你不会看到所有层级的缩进线。
      
      -- char = "▎",
      -- char = "⋮",
      char = "", -- 如果开启，将使用这个字符
      -- char = "┊",
      
      priority = 1, -- 优先级较低
      
      -- 定义彩虹色高亮组 (即使 enable=false，配置依然保留在这里)
      highlights = {
        "BlinkIndentRed",
        "BlinkIndentOrange",
        "BlinkIndentYellow",
        "BlinkIndentGreen",
        "BlinkIndentCyan",
        "BlinkIndentBlue",
        "BlinkIndentViolet",
      },
    },

    -- === 2. 作用域高亮 (Scope) ===
    -- 指的是当前光标所在的那个代码块 (例如当前的 if 块或 function 块)
    scope = {
      enabled = true, -- [!] 重点：这里设置为开启。
      
      -- char = "▎",
      char = "║",      -- 使用“双竖线”字符，非常显眼，用来强调当前正在编辑的代码块
      -- char = "┊",
      -- char = "󰇘",
      -- char = "",
      
      priority = 1000, -- 优先级很高，会覆盖在静态缩进线之上
      
      -- 作用域使用“彩虹色” (Rainbow Scope)
      -- 比如第一层是红色，第二层是黄色... 
      -- 这样你可以通过线条颜色瞬间知道自己嵌套在第几层
      highlights = {
        "BlinkIndentRed",
        "BlinkIndentOrange",
        "BlinkIndentYellow",
        "BlinkIndentGreen",
        "BlinkIndentCyan",
        "BlinkIndentBlue",
        "BlinkIndentViolet",
      },
      
      -- 顶部/底部下划线
      underline = {
        enabled = false, -- 关闭作用域起止行的下划线
        highlights = {
          "BlinkIndentRedUnderline",
          "BlinkIndentOrangeUnderline",
          -- ...
        },
      },
    },
  },
}
