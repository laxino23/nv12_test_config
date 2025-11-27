return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "lewis6991/gitsigns.nvim", -- [关键修复] 添加这行，确保 gitsigns 插件已安装且被加载
    -- 确保 Mason 已经安装了以下工具:
    -- hadolint, markdownlint, mypy, golangci-lint, gomodifytags, impl
  },
  event = { "BufReadPre", "BufNewFile" },
  opts = function()
    local null_ls = require("null-ls")

    -- 简写引用，方便后面调用
    local diagnostics = null_ls.builtins.diagnostics
    local code_actions = null_ls.builtins.code_actions
    -- local completion = null_ls.builtins.completion

    return {
      -- 调试模式，如果工具不工作可以开启查看日志
      debug = false,

      sources = {
        -- =========================================================
        -- 1. Diagnostics (Linting / 代码诊断)
        --    这些工具会在侧边栏显示 错误/警告/提示 图标
        -- =========================================================

        -- Docker: 检查 Dockerfile 最佳实践
        diagnostics.hadolint,

        -- Markdown: 检查 Markdown 规范
        diagnostics.markdownlint.with({
          extra_args = { "--disable", "MD013" },
        }),

        -- Python: 类型检查补充
        diagnostics.mypy.with({
          extra_args = { "--ignore-missing-imports" },
        }),

        -- Go: 强大的 Go 语言 Linter 聚合器
        diagnostics.golangci_lint,

        -- =========================================================
        -- 2. Code Actions (代码操作)
        --    通过 <leader>ca 触发，提供快速修复或重构建议
        -- =========================================================

        -- [注意] 这里就是报错的源头。
        -- 通过在 dependencies 中添加 gitsigns，这里的调用就不会报错了。
        code_actions.gitsigns,

        -- Go: 自动修改 Struct 的 Tags
        code_actions.gomodifytags,

        -- Go: 自动生成接口的实现代码 (Stubs)
        code_actions.impl,
      },
    }
  end,
}
