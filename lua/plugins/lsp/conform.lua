-- 定义一组通用的、通常只需要 Prettier 的文件类型
local supported = {
  "graphql",
  "handlebars",
  "markdown",
  "markdown.mdx",
  "yaml",
  "yaml.docker-compose",
}

-- 定义一组前端核心文件类型 (HTML/CSS/JS/TS)
-- 这些类型通常有多个格式化工具可选 (如 Prettier, Biome, Eslint 等)
local fe_supported = {
  "css",
  "html",
  "javascript",
  "javascriptreact", -- .jsx
  "json",
  "jsonc",
  "less",
  "scss",
  "typescript",
  "typescriptreact", -- .tsx
  "vue",
}

return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- 打开文件时加载

    -- === 快捷键配置 ===
    keys = {
      -- <leader>cf: 格式化当前 buffer
      {
        "<leader>lf",
        function()
          require("conform").format()
        end,
        mode = { "n", "x", "v" },
        desc = "Format",
      },
      -- <leader>cF: 仅格式化“注入语言” (Injected Languages)
      -- 场景：比如你在 Markdown 的 ```lua 代码块``` 中，或者 Python 字符串里的 SQL。
      -- 这个命令只会格式化那个代码块，而不动外层的代码。
      {
        "<leader>lF",
        function()
          require("conform").format({
            formatters = { "injected" },
          })
        end,
        desc = "Conform format injected langs",
        mode = { "n", "v", "x" },
      },
    },

    opts = {
      -- === 保存时自动格式化逻辑 ===
      format_on_save = function(bufnr)
        -- 检查全局变量或当前 buffer 变量是否禁用了自动格式化
        -- (你可以通过 :let g.autoformat = false 来临时禁用)
        if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
          return
        end
        return {
          -- 如果没有配置专门的格式化工具 (如 prettier)，则回退使用 LSP (如 tsserver/lua_ls) 进行格式化
          lsp_format = "fallback",
          timeout_ms = 500, -- 500ms 超时，防止卡顿
        }
      end,

      -- === 后端/系统语言的格式化配置 ===
      formatters_by_ft = {
        query = { "format-queries" }, -- Tree-sitter query 文件
        sh = { "shfmt" }, -- Shell 脚本
        go = { "goimports", "gofmt" }, -- Go: 先跑 imports 整理，再跑 fmt (注意顺序)
        lua = { "stylua" }, -- Lua
        nix = { "nixfmt" }, -- Nix
        rust = { "rustfmt" }, -- Rust
        templ = { "templ" },
        toml = { "taplo" },
      },

      -- 默认格式化选项
      default_format_opts = {
        timeout_ms = 3000, -- 手动格式化时允许更长的超时时间 (3秒)
        async = false, -- 同步执行 (会冻结 UI 直到完成，但保证保存时内容正确)
        quiet = false,
        lsp_format = "fallback",
      },
    },

    init = function()
      -- 设置 formatexpr，这样你可以使用 Vim 原生的 `gq` 快捷键来触发 conform 格式化
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,

    -- === 动态配置逻辑 ===
    config = function(_, opts)
      -- 1. 为通用文件类型绑定 Prettier
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = { "prettier" }
      end

      -- 2. 为前端核心文件绑定 Prettier 和 Biome
      -- 策略：stop_after_first = true
      -- 含义：Conform 会先检查 "prettier" 是否可用（已安装且配置文件存在）。
      --      如果 Prettier 可用，就只用 Prettier。
      --      如果 Prettier 不可用，才会尝试使用 Biome。
      --
      -- 提示：如果你想优先使用 Biome（因为它极快），你应该把 "biome" 放在 "prettier" 前面。
      for _, ft in ipairs(fe_supported) do
        opts.formatters_by_ft[ft] = { "prettier", "biome", stop_after_first = true }
      end

      require("conform").setup(opts)
    end,
  },
}
