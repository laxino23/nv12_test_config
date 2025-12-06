require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "ts_ls",
    "html",
    "cssls",
    "jsonls",
    "yamlls",
    "marksman",
    "gopls",
    "rust_analyzer",
    "clangd",
    "bashls",
    "ruby_lsp",
    "intelephense",
    "nil_ls",
    "terraformls",
    "sqlls",
  },
  automatic_enable = true,
})

-- Update tools based on your Conform config
-- 根据你的 Conform 配置更新工具列表
require("mason-tool-installer").setup({
  ensure_installed = {
    -- Formatters (Synced with your Conform config)
    "stylua", -- Lua
    "prettierd", -- Web (Faster than prettier / 比 prettier 快)
    "prettier", -- Web (Fallback / 备用)
    "black", -- Python
    "isort", -- Python
    "shfmt", -- Shell
    "clang-format", -- C/C++
    "taplo", -- TOML
    "sql-formatter", -- SQL
    "xmlformatter", -- XML
    "cmakelang", -- CMake
    "goimports", -- Go
    "codespell", -- Spell Check
    "php-cs-fixer", -- PHP
    "rubocop", -- Ruby
    "nixpkgs-fmt", -- Nix
    -- Linters (Nvim-lint) - NEW ADDITIONS
    -- 新增的 Linter 工具
    "luacheck", -- Lua
    "pylint", -- Python
    "eslint_d", -- JS/TS/Web (Faster than eslint)
    "golangci-lint", -- Go
    "shellcheck", -- Shell
    "hadolint", -- Docker
    "yamllint", -- YAML
    "markdownlint", -- Markdown
    "tflint", -- Terraform
    "cpplint", -- C/C++ (Optional, clangd does a lot already)
    "phpcs", -- PHP
  },
  auto_update = true,
  run_on_start = true,
  start_delay = 3000,
})
