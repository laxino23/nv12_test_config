return {
  -- ========================================================================
  -- 1. persistence.nvim: 会话管理插件
  -- ========================================================================
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- 在读取文件前加载
    opts = {
      dir = vim.fn.stdpath("state") .. "/sessions/", -- 会话文件的保存目录
      need = 0,
      branch = true, -- 针对不同的 git 分支保存独立的会话
    },
  },

  -- ========================================================================
  -- 2. ts-comments.nvim: 更加智能的注释插件
  -- ========================================================================
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    -- 功能：基于 TreeSitter 识别上下文。
    -- 例如：在 JSX/Vue 文件中，它能自动区分是在 HTML 区域注释（）
    -- 还是在 JS 区域注释（//），比原生的 commentstring 更准确。
  },

  -- ========================================================================
  -- 3. better-escape.nvim: 快速退出插入模式
  -- ========================================================================
  {
    "max397574/better-escape.nvim",
    event = "VeryLazy",
    opts = {
      timeout = vim.o.timeoutlen,
      default_mappings = true,
      mappings = {
        -- i for insert
        i = {
          j = {
            -- These can all also be functions
            k = "<Esc>",
            j = "<Esc>",
          },
        },
        c = {
          j = {
            k = "<C-c>",
            j = "<C-c>",
          },
        },
        t = {
          j = {
            k = "<C-\\><C-n>",
          },
        },
        v = {
          j = {
            k = "<Esc>",
          },
        },
        s = {
          j = {
            k = "<Esc>",
          },
        },
      },
    },
  },
  -- ========================================================================
  -- 4. SmoothCursor.nvim: 光标平滑移动动画
  -- ========================================================================
  {
    "gen740/SmoothCursor.nvim",
    lazy = false,
    opts = {
      type = "default",
      autostart = true,
      fancy = {
        enable = true, -- 开启 "花式" 模式（光标后面带个小尾巴）
        head = { cursor = ">", texthl = "SmoothCursor", linehl = nil }, -- 光标头部形状
        -- 光标尾部的粒子效果配置
        body = {
          { cursor = "󰝥", texthl = "SmoothCursorRed" },
          { cursor = "󰝥", texthl = "SmoothCursorOrange" },
          { cursor = "●", texthl = "SmoothCursorYellow" },
          { cursor = "●", texthl = "SmoothCursorGreen" },
          { cursor = "•", texthl = "SmoothCursorAqua" },
          { cursor = ".", texthl = "SmoothCursorBlue" },
          { cursor = ".", texthl = "SmoothCursorPurple" },
        },
        tail = { cursor = nil, texthl = "SmoothCursor" },
      },
      enabled_filetypes = nil, -- 对所有文件类型启用
      -- 在以下窗口类型中禁用（避免在浮动窗口或文件树中出现光标错位）
      disabled_filetypes = {
        "render-markdown",
        "CodeCompanion",
        "oil",
        "snacks_picker_input",
        "snacks_picker_list",
        "fzf",
      },
    },
    config = function(_, opts)
      require("smoothcursor").setup(opts)
    end,
  },

  -- ========================================================================
  -- 5. visual-whitespace.nvim: 可视模式下显示空格
  -- ========================================================================
  {
    "mcauley-penney/visual-whitespace.nvim",
    event = "VeryLazy",
    config = true,
    opts = {
      -- 仅当你进入 Visual (选择) 模式时，显示选中区域内的空格和制表符。
      -- 这对于查看行尾多余的空格非常有帮助。
      -- highlight = { link = "LineNr" },
    },
  },

  -- ========================================================================
  -- 6. virt-column.nvim: 垂直对齐线 (当前已禁用)
  -- ========================================================================
  {
    "lukas-reineke/virt-column.nvim",
    event = "VeryLazy",
    enabled = false, -- <--- 注意：此插件当前被设置为禁用
    opts = {
      -- 这是一个用来显示 "80字符限制线" 的插件，但它使用的是虚拟文本而不是原来的 colorcolumn
      char = "", -- 垂直线的样式字符
      virtcolumn = "80", -- 线显示在第 80 列
    },
  },

  -- ========================================================================
  -- 7. screenkey.nvim: 屏幕按键显示 (类似直播演示工具)
  -- ========================================================================
  {
    "NStefan002/screenkey.nvim",
    lazy = false,
    opts = {
      win_opts = {
        row = vim.o.lines - vim.o.cmdheight - 1,
        col = vim.o.columns - 1,
        relative = "editor",
        anchor = "SE", -- SE = South East (右下角)
        width = 20,
        height = 2,
        border = "single",
        title = "Screenkey",
        title_pos = "center",
        style = "minimal",
        focusable = false,
        noautocmd = true,
      },
      -- 设置按键显示的颜色高亮
      hl_groups = {
        ["screenkey.hl.key"] = { link = "Type" },
        ["screenkey.hl.map"] = { link = "Keyword" },
        ["screenkey.hl.sep"] = { link = "Normal" },
      },
    },
  },

  -- ========================================================================
  -- 8. stay-centered.nvim: 保持光标垂直居中
  -- ========================================================================
  {
    "arnamak/stay-centered.nvim",
    lazy = false,
    opts = {
      skip_filetypes = {}, -- 不需要在特定文件类型中跳过
    },
    -- 功能：当你上下移动光标时，它会自动滚动屏幕，尽量让光标保持在屏幕的垂直正中间。
    -- 类似于自动执行 "zz" 命令。
  },
  {
    "uga-rosa/ccc.nvim",
    event = "VeryLazy", -- 延迟加载，不拖慢启动速度
    opts = {
      -- 颜色高亮设置（在代码中把 #FFFFFF 或 rgb(0,0,0) 显示为真实的颜色背景）
      highlighter = {
        auto_enable = true, -- 打开文件时自动启用颜色高亮
        lsp = true, -- 启用 LSP 集成（通常用于更好兼容语义高亮，或利用 LSP 发现颜色）
      },
    },
    -- 补充说明：
    -- 1. 这个插件会在你写 CSS/前端代码时，把颜色代码背景变成对应颜色。
    -- 2. 你可以使用 :CccPick 命令调出颜色拾取器面板来选择颜色。
    -- 3. 它支持 Hex, RGB, HSL 等多种格式的转换。
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
        { path = "dart.nvim", words = { "Dart" } },
      },
    },
  },
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      cursor_color = "#a020f0",
      stiffness = 0.8,
      trailing_stiffness = 0.2,
      trailing_exponent = 5,
      damping = 0.6,
      gradient_exponent = 0,
      gamma = 1,
      never_draw_over_target = true, -- if you want to actually see under the cursor
      hide_target_hack = true, -- same
      particles_enabled = false,
      particle_spread = 1,
      particles_per_second = 500,
      particles_per_length = 50,
      particle_max_lifetime = 800,
      particle_max_initial_velocity = 20,
      particle_velocity_from_cursor = 0.5,
      particle_damping = 0.15,
      particle_gravity = -50,
      min_distance_emit_particles = 0,
    },
  },
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },
}
