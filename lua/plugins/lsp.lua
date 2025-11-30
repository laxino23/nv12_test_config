vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim" }, -- tools adder
  { src = "https://github.com/neovim/nvim-lspconfig" }, -- default config
  -- Bridging Mason and Formatters/Linters (The missing piece) / 连接 Mason 和 格式化/Linter 工具
  { src = "https://github.com/whoissethdaniel/mason-tool-installer.nvim" },
  -- Bridging Mason and LSP (The missing piece) / 连接 Mason 和 LSP
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  -- Lspsaga for beautiful UI / Lspsaga 用于美化 UI
  { src = "https://github.com/nvimdev/lspsaga.nvim" },
})

require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗",
    },
  },
})

-- =============================================================================
-- Lspsaga Setup (UI Enhancement)
-- Lspsaga 设置 (UI 增强)
-- =============================================================================
require("lspsaga").setup({
  -- Breadcrumbs / 面包屑导航
  symbol_in_winbar = {
    enable = true,
    separator = " › ",
  },
  -- Lightbulb / 灯泡提示
  lightbulb = {
    enable = true,
    sign = true,
    virtual_text = false,
  },
  -- General UI / 通用 UI
  ui = {
    border = "rounded",
    code_action = "💡",
  },
  -- Scroll keys for preview windows / 预览窗口滚动键
  scroll_preview = {
    scroll_down = "<C-f>",
    scroll_up = "<C-b>",
  },

  -- ---------------------------------------------------------------------------
  -- DIAGNOSTIC CONFIGURATION / 诊断功能配置
  -- ---------------------------------------------------------------------------
  diagnostic = {
    -- Show code action in diagnostic jump window (Very useful!)
    -- 在诊断跳转窗口中显示代码操作(非常有用,推荐开启)
    show_code_action = true,

    -- Show the source of the diagnostic (e.g., "pyright", "eslint")
    -- 显示诊断来源
    show_source = true,

    -- Enable number shortcuts to execute code actions quickly (e.g., press '1' to fix)
    -- 启用数字快捷键以快速执行代码操作(例如按 '1' 修复)
    jump_num_shortcut = true,

    -- Window dimensions / 窗口尺寸
    max_width = 0.7,
    max_height = 0.6,

    -- Text and border highlight follows the severity type (Red for Error, Yellow for Warn)
    -- 文本和边框颜色跟随诊断严重程度(错误为红,警告为黄)
    text_hl_follow = true,
    border_follow = true,

    -- Show related information if available / 显示相关信息
    extend_relatedInformation = false,

    -- Layout for "show_*" commands: 'float' or 'normal'
    -- 诊断列表展示布局:'float' (浮动) 或 'normal' (普通窗口)
    show_layout = "float",

    -- Only show virtual text on the current line (Cleaner UI)
    -- 仅在当前行显示虚拟文本(界面更整洁)
    -- Note: You must disable native virtual_text for this to work best
    diagnostic_only_current = false,

    -- Keymaps inside the diagnostic window / 诊断窗口内的按键映射
    keys = {
      exec_action = "o", -- Execute action / 执行操作
      quit = "q", -- Quit window / 退出窗口
      toggle_or_jump = "<CR>", -- Jump to location / 跳转到位置
      quit_in_show = { "q", "<ESC>" }, -- Keys to quit "show" window / 退出列表窗口的键
    },
  },
})

-- =============================================================================
-- 个性化配置 (vim.lsp.config)
-- 注意:必须在 mason-lspconfig.setup 之前定义这些,
-- 这样当 mason 自动启动服务时,能应用你的个性化设置。
-- =============================================================================

-- [Lua] lua_ls (智能识别 Neovim 环境 vs 普通 Lua 项目)
vim.lsp.config("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      -- 如果检测到 .luarc.json,说明是普通项目,不加载 Neovim 插件库
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end
    -- 否则加载 Neovim 运行时库
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = { version = "LuaJIT" },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
    })
  end,
  settings = {
    Lua = {
      codeLens = { enable = true },
      hint = { enable = true, semicolon = "Disable" },
      diagnostics = {
        globals = { "vim", "Snacks", "MiniIcons" },
      },
    },
  },
})

-- [Python] pyright (优化性能)
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly", -- 仅检查打开的文件
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- [Rust] rust_analyzer
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = true,
      },
      lens = {
        enable = true,
      },
      checkOnSave = {
        command = "clippy",
      },
    },
  },
})

-- [C/C++] clangd
vim.lsp.config("clangd", {
  cmd = { "clangd", "--offset-encoding=utf-16" },
})

-- =============================================================================
-- Mason-LSPConfig 设置 (桥接与自动启动)
-- =============================================================================
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "ts_ls",
    "html",
    "cssls",
    "jsonls",
    "yamlls",
    "marksman", -- Markdown
    "gopls", -- Go
    "rust_analyzer", -- Rust
    "clangd", -- C/C++
    "bashls", -- Shell
    "ruby_lsp", -- Ruby
    "intelephense", -- PHP
    "nil_ls", -- Nix
    "terraformls",
    "sqlls",
  },

  -- 2. 自动启用 (Automatic Enable)
  -- 这一步会对上面列表中安装好的每一个服务运行 vim.lsp.enable()
  automatic_enable = true,
})

-- =============================================================================
-- Mason Tool Installer (Auto-install formatters/linters)
-- 自动安装格式化工具和 Linter
-- =============================================================================
require("mason-tool-installer").setup({
  -- List of tools to auto-install / 自动安装的工具列表
  -- Find names here: https://mason-registry.dev/registry/list
  ensure_installed = {
    -- Lua
    "stylua",

    -- Web (HTML, CSS, JS, JSON, Markdown)
    "prettier", -- or "prettierd"

    -- Python
    "black",
    "isort",

    -- Shell
    "shfmt",

    -- C/C++
    "clang-format",

    -- TOML
    "taplo",

    -- SQL
    "sql-formatter",

    -- XML
    "xmlformatter",

    -- CMake
    "cmakelang", -- contains cmake-format

    -- Go
    "goimports",
    -- "gofmt", -- usually part of go toolchain, not mason / 通常属于 go 工具链,不在 mason 中

    -- Rust
    -- "rustfmt", -- usually managed by rustup, not mason / 通常由 rustup 管理
  },

  auto_update = true,
  run_on_start = true,
  start_delay = 3000, -- 3 seconds / 3秒
})

-- =============================================================================
-- Helper Functions / 辅助函数
-- =============================================================================

-- 跳到当前函数开头
local function jump_to_current_function_start()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
  if not responses then
    return
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local line = pos[1] - 1

  local function find_symbol(symbols)
    for _, s in ipairs(symbols) do
      local range = s.range or (s.location and s.location.range)
      if range and line >= range.start.line and line <= range["end"].line then
        if s.children then
          local child = find_symbol(s.children)
          if child then
            return child
          end
        end
        return s
      end
    end
  end

  for _, resp in pairs(responses) do
    local sym = find_symbol(resp.result or {})
    if sym and sym.range then
      vim.api.nvim_win_set_cursor(0, { sym.range.start.line + 1, 0 })
      return
    end
  end
end

-- 跳到当前函数结尾
local function jump_to_current_function_end()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
  if not responses then
    return
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local line = pos[1] - 1

  local function find_symbol(symbols)
    for _, s in ipairs(symbols) do
      local range = s.range or (s.location and s.location.range)
      if range and line >= range.start.line and line <= range["end"].line then
        if s.children then
          local child = find_symbol(s.children)
          if child then
            return child
          end
        end
        return s
      end
    end
  end

  for _, resp in pairs(responses) do
    local sym = find_symbol(resp.result or {})
    if sym and sym.range then
      vim.api.nvim_win_set_cursor(0, { sym.range["end"].line + 1, 0 })
      return
    end
  end
end

-- =============================================================================
-- LspAttach 自动命令 (按键映射与增强功能)
-- =============================================================================
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(event)
    local function map(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    -- 1. Standard Lspsaga commands / 标准 Lspsaga 命令
    map("K", "<cmd>Lspsaga hover_doc<CR>", "Hover Documentation")
    map("gr", "<cmd>Lspsaga finder<CR>", "Finder (Refs/Def)")
    map("<leader>ca", "<cmd>Lspsaga code_action<CR>", "Code Action")
    map("<leader>rn", "<cmd>Lspsaga rename<CR>", "Rename")

    -- 2. Diagnostic Commands (The part you requested) / 诊断命令(你要求的部分)

    -- Jump to Next/Prev Diagnostic (Float window appears automatically)
    -- 跳转到 下一个/上一个 诊断(会自动弹出浮动窗口)
    map("]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", "Next Diagnostic")
    map("[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Prev Diagnostic")

    -- Jump to Error ONLY (Skip warnings) / 仅跳转到错误(跳过警告)
    map("]E", function()
      require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, "Next Error")
    map("[E", function()
      require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, "Prev Error")

    -- Show diagnostics for current line / 显示当前行诊断
    map("<leader>ldl", "<cmd>Lspsaga show_line_diagnostics<CR>", "Show Line Diagnostics")

    -- Show diagnostcs for cursor / 显示光标处诊断
    map("<leader>ldw", "<cmd>Lspsaga show_cursor_dagnostics<CR>", "Show Cursor Diagnostics")

    -- Show diagnostics for buffer (List view) / 显示当前文件所有诊断(列表视图)
    map("<leader>ldb", "<cmd>Lspsaga show_buf_diagnostics<CR>", "Show Buffer Diagnostics")

    -- Show diagnostics for workspace / 显示工作区所有诊断
    map("<leader>ldd", "<cmd>Lspsaga show_workspace_diagnostics<CR>", "Show Workspace Diagnostics")

    -- 3. Custom Goto Definition (Snacks Integration)
    map("gtd", function()
      if package.loaded["snacks"] then
        require("snacks").picker.lsp_definitions()
      else
        vim.lsp.buf.definition()
      end
    end, "Goto Definition")

    -- 4. 函数跳转逻辑 ([f / ]f)
    map("[f", jump_to_current_function_start, "Jump to function start")
    map("]f", jump_to_current_function_end, "Jump to function end")

    -- 5. Inlay Hints 开关 (如果你用 Neovim 0.10+)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
      end, "[T]oggle Inlay [H]ints")
    end
  end,
})
