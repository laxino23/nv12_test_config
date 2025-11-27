return {
  -- =========================================================================
  -- 1. nvim-treesitter: 提供基于语法树的高亮、缩进、折叠等核心功能
  -- =========================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    -- 优化启动速度：如果启动 nvim 时没有带参数（比如直接输入 nvim 打开），
    -- 则延迟加载；如果打开了具体文件，则立即加载。
    lazy = vim.fn.argc(-1) == 0,
    branch = "main",
    version = false,
    event = "VeryLazy", -- 在非常靠后的时机加载（作为兜底）
    build = ":TSUpdate", -- 安装或更新插件后，自动运行 :TSUpdate 更新解析器
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts_extend = { "ensure_installed" }, -- 允许其他插件扩展 ensure_installed 列表

    -- 核心配置选项
    opts = {
      indent = { enable = true }, -- 启用基于 Treesitter 的缩进
      highlight = { enable = true }, -- 启用基于 Treesitter 的语法高亮（比正则更准确）
      folds = { enable = true }, -- 启用基于 Treesitter 的代码折叠

      -- 确保自动安装以下语言的解析器 (Parser)
      ensure_installed = {
        "bash",
        "dockerfile",
        "fish",
        "git_config",
        "gitcommit",
        "git_rebase",
        "gitignore",
        "gitattributes",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "c",
        "diff",
        "html",
        "css",
        "javascript",
        "jsdoc",
        "tsx",
        "typescript",
        "json",
        "jsonc",
        "json5",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "ninja",
        "rst",
        "regex",
        "toml",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
        "typst",
        "rust",
        "ron",
        "java",
      },
    },

    -- 自定义配置函数
    config = function(_, opts)
      -- 安装列表中的解析器并应用设置
      require("nvim-treesitter").install(opts.ensure_installed or {})
      require("nvim-treesitter").setup(opts)

      -- 将 scss 的解析器应用到 less 和 postcss 文件类型上
      vim.treesitter.language.register("scss", "less")
      vim.treesitter.language.register("scss", "postcss")

      -- 定义一个辅助函数：用于开启当前 buffer 的 Treesitter 功能
      -- 并设置缩进表达式和折叠表达式
      local function attach(bufnr, winnr)
        vim.treesitter.start(bufnr)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.wo[winnr][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
      end

      -- NOTE: 自动安装缺失解析器的逻辑
      -- 下面的自动命令会在打开文件时触发
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
        callback = function(ev)
          local bufnr, ft = ev.buf, ev.match
          local winnr = vim.api.nvim_get_current_win()

          -- 尝试直接启动 Treesitter
          local ok = pcall(attach, bufnr, winnr)

          -- 如果启动失败（通常是因为没有下载对应的语言解析器）
          if not ok then
            -- 获取当前文件类型对应的语言
            local lang = vim.treesitter.language.get_lang(ft) or ft
            -- 如果语言无效或者不在可用列表中，则忽略
            if
              lang == ""
              or not vim.tbl_contains(require("nvim-treesitter.config").get_available(), lang)
            then
              return
            end

            -- 自动尝试下载并安装该语言的解析器
            require("nvim-treesitter").install(lang):await(function(_, did_install)
              -- 安装完成后，再次尝试启动 Treesitter 功能
              if did_install then
                attach(bufnr, winnr)
              end
            end)
          end
        end,
      })
    end,
  },

  -- =========================================================================
  -- 2. nvim-treesitter-textobjects: 基于语法树的文本对象跳转
  --    允许你使用 ]f, [f 等快捷键在函数、类、参数之间快速跳转
  -- =========================================================================
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = true,
    branch = "main",
    -- 定义快捷键映射
    keys = function()
      local move = require("nvim-treesitter-textobjects.move")
      return {
        -- === 参数 (Parameter) 跳转 ===
        {
          "]a", -- 跳转到下一个参数的【开始】位置
          function()
            move.goto_next_start("@parameter.inner", "textobjects")
          end,
          mode = { "n", "x", "o" }, -- 支持正常(n)、可视(x)、操作符等待(o)模式
        },
        {
          "]A", -- 跳转到下一个参数的【结束】位置
          function()
            move.goto_next_end("@parameter.inner", "textobjects")
          end,
          mode = { "n", "x", "o" },
        },
        {
          "[a", -- 跳转到上一个参数的【开始】位置
          function()
            move.goto_previous_start("@parameter.inner", "textobjects")
          end,
          mode = { "n", "x", "o" },
        },
        {
          "[A", -- 跳转到上一个参数的【结束】位置
          function()
            move.goto_previous_end("@parameter.inner", "textobjects")
          end,
          mode = { "n", "x", "o" },
        },

        -- === 类 (Class) 跳转 ===
        {
          "]c", -- 跳转到下一个类的【开始】位置
          function()
            move.goto_next_start("@class.outer", "textobjects")
          end,
          mode = { "n", "x", "o" },
        },
        {
          "]C", -- 跳转到下一个类的【结束】位置
          function()
            move.goto_next_end("@class.outer", "textobjects")
          end,
          mode = { "n", "x", "o" },
        },
        {
          "[c", -- 跳转到上一个类的【开始】位置
          function()
            move.goto_previous_start("@class.outer", "textobjects")
          end,
          mode = { "n", "x", "o" },
        },
        {
          "[C", -- 跳转到上一个类的【结束】位置
          function()
            move.goto_previous_end("@class.outer", "textobjects")
          end,
          mode = { "n", "x", "o" },
        },

        -- === 函数 (Function) 跳转 ===
        {
          "]f", -- 跳转到下一个函数的【开始】位置
          function()
            move.goto_next_start("@function.outer", "textobjects")
          end,
          mode = { "n", "x", "o" },
        },
        {
          "]F", -- 跳转到下一个函数的【结束】位置
          function()
            move.goto_next_end("@function.outer", "textobjects")
          end,
          mode = { "n", "x", "o" },
        },
        {
          "[f", -- 跳转到上一个函数的【开始】位置
          function()
            move.goto_previous_start("@function.outer", "textobjects")
          end,
          mode = { "n", "x", "o" },
        },
        {
          "[F", -- 跳转到上一个函数的【结束】位置
          function()
            move.goto_previous_end("@function.outer", "textobjects")
          end,
          mode = { "n", "x", "o" },
        },
      }
    end,
  },
}
