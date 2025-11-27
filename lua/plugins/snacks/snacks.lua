return {
  {
    "folke/snacks.nvim",
    -- lazy = false: 禁止延迟加载。
    -- 因为 Snacks 接管了启动界面、通知(notify)和输入框(input)等核心 UI，需要启动时立即加载。
    lazy = false,
    -- priority = 1000: 设置最高优先级，确保它在其他可能依赖它的插件之前加载。
    priority = 1000,

    -- opts: 在这里启用或禁用 Snacks 提供的各个子模块
    opts = {
      -- explorer: 文件资源管理器 (类似 Neo-tree 或 Nvim-tree)
      -- replace_netrw = false: 这里设为 false，表示不替换 Neovim 原生的 netrw 浏览功能
      explorer = { enabled = true, replace_netrw = false },

      -- image: 图像支持 (在终端内预览图片，需要终端模拟器支持，如 Kitty, WezTerm, iTerm2)
      image = { enabled = true },

      -- dim: 暗淡非活跃代码 (类似 Twilight.nvim)，这里设置为关闭
      dim = { enabled = false },

      -- zen: 禅模式 (Zen Mode)，隐藏周围 UI 让你专注写代码
      zen = { enabled = true },

      -- scroll: 平滑滚动动画，这里设置为关闭
      scroll = { enabled = true },

      -- input: 美化 vim.ui.input (重命名文件或输入搜索时的弹窗)
      input = { enabled = true },

      -- words: 光标下的词汇自动高亮 (类似 vim-illuminate)，并支持在这些词之间跳转
      words = { enabled = true },

      -- statuscolumn: 自定义左侧的状态列 (显示行号、Git 符号、折叠图标的区域)
      statuscolumn = {
        left = { "mark", "sign" }, -- 左侧优先显示：书签(mark) 和 诊断符号(sign, 如报错红点)
        right = { "fold", "git" }, -- 右侧优先显示：折叠箭头 和 Git 变更竖条
        folds = {
          open = true, -- 显示展开状态的折叠图标
          git_hl = true, -- 折叠图标使用 Git 的颜色 (例如修改过的代码块折叠图标是蓝色的)
        },
      },

      -- notifier: 通知系统 (美化右下角的通知弹窗，替代 nvim-notify)
      notifier = { enabled = true },

      -- toggle: 开关引擎 (用于定义下面 init 函数里的快捷键)
      toggle = { enabled = true },

      -- lazygit: 浮动终端运行 Lazygit，这里关闭了 (可能因为你有专门的 lazygit 插件)
      lazygit = { enabled = false },

      -- terminal: 简单的浮动终端管理
      terminal = { enabled = true },

      -- scope: 作用域高亮 (在缩进线上显示当前代码块的范围)
      scope = { enabled = true },

      -- gitbrowse: 快速在浏览器中打开当前代码行对应的 GitHub/GitLab 链接
      gitbrowse = { enabled = true },
    },

    -- init: 在插件加载时执行的初始化代码，主要用于设置快捷键
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy", -- 等到 Neovim 完全启动后再绑定键位
        callback = function()
          -- === 创建 Toggle (开关) 快捷键 ===
          -- 这些快捷键通常以 <leader>u 开头 (u 代表 UI/User interface)

          -- <leader>us: 开关拼写检查 (Spell Check)
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")

          -- <leader>uw: 开关自动换行 (Wrap)
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")

          -- <leader>uL: 开关相对行号 (Relative Number)
          -- 开启时显示相对行号(方便跳转)，关闭时显示普通行号
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")

          -- <leader>ud: 开关诊断信息 (Diagnostics)
          -- 快速隐藏/显示代码中的报错、警告信息
          Snacks.toggle.diagnostics():map("<leader>ud")

          -- <leader>ul: 开关行号显示 (Line Number)
          -- 彻底隐藏/显示左侧行号栏
          Snacks.toggle.line_number():map("<leader>ul")

          -- <leader>uc: 开关隐藏级别 (Conceal Level)
          -- 主要用于 Markdown 或 JSON。
          -- 开启时：隐藏 Markdown 的 **bold** 标记或链接 URL，只显示渲染后的文字。
          -- 关闭时：显示所有原始字符。
          Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>uc")

          -- <leader>uT: 开关 Treesitter (语法高亮)
          -- 如果文件太大导致卡顿，可以用这个快速关闭高亮
          Snacks.toggle.treesitter():map("<leader>uT")

          -- <leader>ub: 开关背景明暗 (Light/Dark Background)
          Snacks.toggle
            .option("background", { off = "light", on = "dark", name = "Dark Background" })
            :map("<leader>ub")

          -- <leader>uh: 开关内嵌提示 (Inlay Hints)
          -- 开启时，在代码中显示参数名称或类型推断 (例如: function(name: "John"))
          Snacks.toggle.inlay_hints():map("<leader>uh")

          -- <leader>ug: 开关缩进参考线 (Indent Guides)
          -- 显示代码缩进的竖线
          Snacks.toggle.indent():map("<leader>ug")

          -- <leader>uD: 开关暗淡模式 (Dim)
          -- 开启后，将当前光标不在的行变暗，帮助专注
          Snacks.toggle.dim():map("<leader>uD")
        end,
      })
    end,
  },
}
