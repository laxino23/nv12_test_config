return {
  "mason-org/mason.nvim",
  build = ":MasonUpdate", -- 插件安装/更新时，自动更新 Mason 的注册表
  cmd = "Mason", -- 输入 :Mason 命令时加载
  event = { "BufNewFile", "BufReadPre" }, -- 打开文件时自动加载
  opts_extend = { "ensure_installed" }, -- 允许其他插件扩展 ensure_installed 列表

  -- 定义打开 Mason UI 的快捷键: <leader>cm
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },

  opts = {
    -- Python 相关配置
    pip = {
      upgrade_pip = true, -- 自动升级 pip 版本
    },

    -- Mason 弹窗 UI 配置
    ui = {
      border = vim.g.bordered and "rounded" or "none", -- 跟随全局边框设置
      backdrop = 100, -- 背景遮罩透明度 (0-100)
      height = 0.65, -- 窗口高度比例
      width = 0.7, -- 窗口宽度比例
    },

    -- === 核心：确保安装的工具列表 ===
    -- 这里包含了 LSP(语言服务器), DAP(调试器), Linter(检查), Formatter(格式化)
    ensure_installed = {
      -- Lua
      "lua-language-server", -- LSP
      "emmylua_ls", -- LSP (旧版，通常一个 lua_ls 够用了)
      "stylua", -- Formatter (格式化 Lua 代码)

      -- Markdown
      "marksman", -- LSP
      "markdownlint", -- Markdown linter

      -- Docker / Shell
      "dockerfile-language-server",
      "docker-compose-language-service",
      "bash-language-server",
      "shfmt", -- Shell 格式化
      "shellcheck", -- Shell 静态检查

      -- Linter for Dockerfiles
      "hadolint",

      -- Web (HTML/CSS/JS/TS)
      "html-lsp",
      "css-lsp",
      "eslint-lsp",
      "prettier", -- 强大的前端格式化工具
      "biome", -- 极速 Web 工具链 (Linter/Formatter)
      "vtsls", -- TypeScript LSP (高性能)
      "js-debug-adapter", -- JS 调试器

      -- JSON
      "json-lsp",

      -- Go 语言全家桶
      "gopls", -- LSP
      "goimports", -- Formatter (自动导包)
      "golines", -- Formatter (缩短长行)
      "golangci-lint-langserver", -- Linter
      "delve", -- Debugger (调试器)
      "gomodifytags", -- Tool (修改 struct tag)
      "gotests", -- Tool (自动生成测试)
      "iferr", -- Tool (生成 err != nil)
      "impl", -- Tool (生成接口实现)
      "golangci-lint", -- Go linter

      -- Rust
      "rust-analyzer", -- LSP

      -- Java
      "jdtls", -- LSP
      "java-debug-adapter", -- Debugger
      "java-test", -- Test Runner

      -- C/C++ 调试器
      "codelldb",

      -- Python
      "pyright", -- LSP (类型检查)
      "ruff", -- Linter/Formatter (极速)
      "mypy", -- Python type checker

      -- TOML / XML
      "taplo", -- TOML LSP
      "lemminx", -- XML LSP

      -- YAML
      "yaml-language-server",
    },
  },

  -- === 自定义配置逻辑 ===
  config = function(_, opts)
    require("mason").setup(opts)

    local registry = require("mason-registry")

    -- 1. 监听安装成功事件 (实现即时生效)
    -- 当某个工具安装完成后，自动触发 FileType 事件。
    -- 这通常是为了让 LSP 客户端 (nvim-lspconfig) 检测到新安装的服务器并立即启动，
    -- 而不需要你重启 Neovim。
    registry:on("package:install:success", function()
      vim.defer_fn(function()
        require("lazy.core.handler.event").trigger({
          event = "FileType",
          buf = vim.api.nvim_get_current_buf(),
        })
      end, 100)
    end)

    -- 2. 自动安装缺失工具的循环
    -- 这是一个自定义的自动安装脚本。它会刷新注册表，然后遍历 `ensure_installed` 表，
    -- 如果发现有没安装的工具，就自动开始安装。
    registry.refresh(function()
      for _, tool in ipairs(opts.ensure_installed) do
        local p = registry.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end)
  end,
}
