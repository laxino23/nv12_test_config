-- =============================================================================
-- Conform Setup / Conform 配置
-- =============================================================================
local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    -- Lua
    lua = { "stylua" },
    -- Python
    python = { "isort", "black" },
    -- JavaScript/TypeScript (Web Stack)
    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    vue = { "prettierd", "prettier", stop_after_first = true },
    svelte = { "prettierd", "prettier", stop_after_first = true },
    -- Web Development (HTML/CSS/JSON/YAML)
    html = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettierd", "prettier", stop_after_first = true },
    scss = { "prettierd", "prettier", stop_after_first = true },
    less = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    jsonc = { "prettierd", "prettier", stop_after_first = true },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    graphql = { "prettierd", "prettier", stop_after_first = true },
    -- Markdown
    markdown = { "prettierd", "prettier", stop_after_first = true },
    ["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },
    -- Configuration Files
    toml = { "taplo" },
    xml = { "xmlformat" },
    -- Go
    go = { "goimports", "gofmt" },
    -- Rust
    rust = { "rustfmt", lsp_format = "fallback" },
    -- Swift
    swift = { "swift_format" },
    -- C/C++
    c = { "clang_format" },
    cpp = { "clang_format" },
    cmake = { "cmake_format" },
    -- Shell
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    -- Ruby
    ruby = { "rubocop" },
    -- PHP
    php = { "php_cs_fixer" },
    -- Nix
    nix = { "nixpkgs_fmt" },
    -- Terraform
    terraform = { "terraform_fmt" },
    hcl = { "terraform_fmt" },
    -- SQL
    sql = { "sql_formatter" },
    -- Global & Fallback
    ["*"] = { "codespell" },
    ["_"] = { "trim_whitespace" },
  },

  default_format_opts = {
    lsp_format = "fallback",
    timeout_ms = 3000,
  },

  -- Logic: Disable autoformat if global variable is set
  -- 逻辑：如果设置了全局变量，则禁用自动格式化
  format_on_save = function(bufnr)
    if vim.g.disable_autoformat then
      return
    end
    return {
      lsp_format = "fallback",
      timeout_ms = 1000,
    }
  end,

  log_level = vim.log.levels.WARN,
  notify_on_error = true,
  notify_no_formatters = false,

  formatters = {
    shfmt = {
      prepend_args = { "-i", "2", "-ci" },
    },
    clang_format = {
      prepend_args = { "--style=Google" },
    },
    taplo = {
      -- args = { "format", "-" },
    },
  },
})

-- =============================================================================
-- Commands / 命令
-- =============================================================================

vim.api.nvim_create_user_command("FormatToggle", function()
  if vim.g.disable_autoformat then
    vim.g.disable_autoformat = false
    vim.notify("Format on save enabled / 保存时格式化已启用", vim.log.levels.INFO)
  else
    vim.g.disable_autoformat = true
    vim.notify("Format on save disabled / 保存时格式化已禁用", vim.log.levels.WARN)
  end
end, { desc = "Toggle format on save" })

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil
  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end
  require("conform").format({ async = true, lsp_format = "fallback", range = range })
end, { range = true, desc = "Format code" })

-- =============================================================================
-- Keymaps / 按键映射
-- =============================================================================

local function formatbuf()
  require("conform").format({
    lsp_format = "fallback",
    async = false,
    timeout_ms = 3000,
  })
end

-- Using standard vim.keymap.set to keep this file self-contained
-- 使用标准 vim.keymap.set 以保持此文件独立
local map = vim.keymap.set

map({ "n", "v" }, "<leader>lf", formatbuf, { desc = "Format current buffer", silent = true })
map("n", "<leader>fi", "<cmd>ConformInfo<cr>", { desc = "Formatter info", silent = true })
map("n", "<leader>lt", "<cmd>FormatToggle<cr>", { desc = "Toggle format on save", silent = true })
