-- 引入外部的工具模块和 UI 配置
local ui = require("config.ui") -- 引用之前配置好的图标

return {
  "neovim/nvim-lspconfig",
  event = {
    "BufReadPre", -- 打开文件前加载
    "BufNewFile", -- 创建新文件时加载
  },
  dependencies = {
    "mason-org/mason.nvim", -- 用于方便地安装 LSP 二进制文件
  },
  config = function()
    local lspUtil = require("config.lsp") -- 这里面通常包含具体的 keymap 绑定逻辑 (on_attach)
    -- =======================================================================
    -- 1. 诊断信息 (Diagnostic) 全局配置
    --    控制报错、警告等信息在界面上如何显示
    -- =======================================================================
    vim.diagnostic.config({
      underline = true, -- 给报错的代码下方加下划线
      update_in_insert = false, -- 插入模式(打字时)不更新诊断，减少干扰，退出插入模式才更新

      -- [!] 重要：关闭行尾的虚拟文本提示 (Ghost text)
      -- 设置为 false 后，报错信息不会直接显示在代码行尾，
      -- 你可能需要把光标移上去或者按快捷键查看浮窗。
      virtual_text = false,
      virtual_lines = false, -- 关闭多行虚拟文本

      -- 浮动窗口配置 (当光标悬停查看错误时的弹窗)
      float = {
        border = vim.g.bordered and "rounded" or "none", -- 边框样式
        spacing = 4,
        source = "if_many", -- 如果有多个来源则显示来源
        prefix = "● ", -- 列表前缀
      },
      severity_sort = true, -- 按严重程度排序 (错误 > 警告 > 提示)

      -- 左侧侧边栏的图标设置 (使用 config.ui 中的图标)
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = ui.icons.diagnostics.Error,
          [vim.diagnostic.severity.WARN] = ui.icons.diagnostics.Warn,
          [vim.diagnostic.severity.HINT] = ui.icons.diagnostics.Hint,
          [vim.diagnostic.severity.INFO] = ui.icons.diagnostics.Info,
        },
        -- 设置高亮组 (颜色)
        texthl = {
          [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
          [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
          [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
          [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
          [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
          [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
          [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
        },
      },
    })

    -- =======================================================================
    -- 2. Capabilities (能力集) 配置
    --    告诉 LSP 服务器客户端(Neovim)支持哪些功能 (如补全、折叠等)
    -- =======================================================================
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    -- 扩展默认能力
    vim.tbl_deep_extend("force", capabilities, {
      workspace = {
        fileOperations = {
          didRename = true, -- 支持文件重命名操作
          willRename = true,
        },
      },
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true, -- 告诉 LSP 我们支持基于 LSP 的代码折叠 (用于 nvim-ufo 等)
        },
      },
    })

    -- [!] 关键集成：blink.cmp
    -- 这里将 blink.cmp (补全插件) 的能力注入到 LSP 配置中。
    -- 如果你用的是 nvim-cmp，这里通常是 require('cmp_nvim_lsp').default_capabilities()
    capabilities = vim.tbl_deep_extend(
      "force",
      capabilities,
      require("blink.cmp").get_lsp_capabilities(capabilities, true)
    )

    -- 为所有 (*) LSP 服务器应用这个能力配置
    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    -- =======================================================================
    -- 3. 启用具体的 LSP 服务器
    -- =======================================================================
    vim.lsp.enable({
      "lua_ls", -- Lua
      -- "emmylua_ls",

      "bashls", -- Bash

      "dockerls", -- Dockerfile
      "docker_compose_language_service",

      "html", -- HTML
      "cssls", -- CSS
      "biome", -- Web 前端高性能工具链
      "eslint", -- JS/TS 检查
      "vtsls", -- TypeScript (比 tsserver 更快)
      "vuels", -- Vue

      "gopls", -- Go
      "golangci_lint_ls",

      "jsonls", -- JSON

      "marksman", -- Markdown

      "pyright", -- Python 类型检查
      "ruff", -- Python 极速 Linter/Formatter

      "yamlls", -- YAML

      "taplo", -- TOML

      "zls", -- Zig
    })

    -- =======================================================================
    -- 4. 动态能力注册处理 (Dynamic Capability Registration)
    --    这是一段高级配置，用于处理某些 LSP 服务器"后知后觉"的情况
    -- =======================================================================
    local Methods = vim.lsp.protocol.Methods
    -- 有些 LSP 服务器启动时不注册所有功能，而是运行一会后动态注册。
    -- 这段代码拦截了 `client_registerCapability` 请求，
    -- 确保当服务器动态添加新功能时，能够重新触发 on_attach (绑定快捷键)。
    local register_capability = vim.lsp.handlers[Methods.client_registerCapability]
    vim.lsp.handlers[Methods.client_registerCapability] = function(err, res, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if not client then
        return
      end

      -- 如果服务器注册了新能力，重新运行我们的挂载逻辑
      lspUtil.on_attach(client, vim.api.nvim_get_current_buf())
      return register_capability(err, res, ctx)
    end

    -- =======================================================================
    -- 5. LspAttach 自动命令
    --    当 LSP 成功连接到当前 buffer 时触发
    -- =======================================================================
    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "Configure LSP keymaps",
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        assert(client ~= nil, "Client is not available for buffer")

        -- 调用 utils/lsp.lua 中的 on_attach 函数
        -- 这里通常用来设置 gd (跳转定义), K (查看文档), <leader>rn (重命名) 等快捷键
        lspUtil.on_attach(client, args.buf)
      end,
    })
  end,
}
