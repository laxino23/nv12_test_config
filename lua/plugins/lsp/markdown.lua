return {
  -- =========================================================
  -- 1. 浏览器实时预览 (Browser Preview)
  --    当你写文档需要看最终 HTML 样式时使用
  -- =========================================================
  {
    "iamcco/markdown-preview.nvim",
    -- 只有当输入这些命令时才加载插件
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },

    -- [构建步骤] 这是一个著名的坑点。
    -- 因为这个插件依赖 Node.js 编译的 server，lazy.nvim 安装时需要手动触发安装脚本。
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,

    keys = {
      {
        "<leader>cp", -- mnemonic: [C]ode [P]review
        ft = "markdown", -- 只有在 markdown 文件中生效
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview (浏览器预览)",
      },
    },
    -- 确保文件类型正确加载
    config = function()
      vim.cmd([[do FileType]])
    end,
  },

  -- =========================================================
  -- 2. 编辑器内美化 (In-Editor Rendering)
  --    把 Neovim 变成类似 Obsidian 的富文本编辑器体验
  -- =========================================================
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- 依赖树：需要 Treesitter 解析语法，需要 mini.icons 显示图标
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },

    -- 支持的文件类型：除了 md，还支持 org-mode 和 CodeCompanion (AI对话窗口)
    ft = { "markdown", "norg", "rmd", "org", "codecompanion" },

    opts = {
      -- 开启 blink.cmp 的补全支持 (如果你用的是 blink)
      completions = { blink = { enabled = true } },

      -- 代码块渲染设置
      code = {
        language_border = "", -- 代码块语言名称周围不加边框，更简洁
        width = "block", -- 代码块背景色铺满整行 (看起来更像 VS Code)
        right_pad = 1, -- 右侧留一点内边距
      },
    },

    config = function(_, opts)
      require("render-markdown").setup(opts)

      -- 集成 Snacks.nvim 的 Toggle 功能
      -- 快捷键: <leader>um (User Markdown)
      -- 作用: 快速开关“美化模式”。有时候你需要看原始的 Markdown 源码（比如看有多少个空格），可以按这个键暂时关闭渲染。
      Snacks.toggle({
        name = "Render Markdown",
        get = require("render-markdown").get,
        set = require("render-markdown").set,
      }):map("<leader>um")
    end,
  },
}
