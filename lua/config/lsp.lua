local M = {}

-- ===========================================================================
-- 1. Picker (选择器) 抽象层
--    这里实现了一个策略模式：根据 vim.g.picker 的值，
--    决定使用 Fzf-lua 还是 Snacks.picker 来显示查找界面。
-- ===========================================================================
local is_fzf_picker = vim.g.picker == "fzf"
local fzflua = require("fzf-lua")

-- 下面定义了一系列局部函数，用于封装 LSP 查找操作
-- 如果全局设置是用 fzf，就调 fzf-lua；否则调 snacks.picker

local function lsp_definitions()
  if is_fzf_picker then
    fzflua.lsp_definitions()
  else
    Snacks.picker.lsp_definitions()
  end
end

local function lsp_declarations()
  if is_fzf_picker then
    fzflua.lsp_declarations()
  else
    Snacks.picker.lsp_declarations()
  end
end

local function lsp_implementations()
  if is_fzf_picker then
    fzflua.lsp_implementations()
  else
    Snacks.picker.lsp_implementations()
  end
end

local function lsp_references()
  if is_fzf_picker then
    fzflua.lsp_references()
  else
    Snacks.picker.lsp_references()
  end
end

local function lsp_type_definitions()
  if is_fzf_picker then
    fzflua.lsp_typedefs()
  else
    Snacks.picker.lsp_type_definitions()
  end
end

local function lsp_incoming_calls()
  if is_fzf_picker then
    fzflua.lsp_incoming_calls()
  else
    Snacks.picker.lsp_incoming_calls()
  end
end

local function lsp_outgoing_calls()
  if is_fzf_picker then
    fzflua.lsp_outgoing_calls()
  else
    Snacks.picker.lsp_outgoing_calls()
  end
end

local function lsp_symbols() -- 当前文件的符号 (Outline)
  if is_fzf_picker then
    fzflua.lsp_document_symbols()
  else
    Snacks.picker.lsp_symbols()
  end
end

local function lsp_workspace_symbols() -- 整个工作区的符号
  if is_fzf_picker then
    fzflua.lsp_workspace_symbols()
  else
    Snacks.picker.lsp_workspace_symbols()
  end
end

-- 诊断信息 (Diagnostics) 查找
local function diagnostics_buffer()
  if is_fzf_picker then
    fzflua.diagnostics_document()
  else
    Snacks.picker.diagnostics_buffer()
  end
end

-- 工作区诊断信息 (包含自定义排序)
local function diagnostics_workspace()
  if is_fzf_picker then
    fzflua.diagnostics_workspace()
  else
    Snacks.picker.diagnostics({
      sort = {
        fields = { "severity", "is_current", "is_cwd", "file", "lnum" }, -- 优先按严重程度排序
      },
    })
  end
end

-- 仅查找警告 (Warnings)
local function diagnostics_workspace_warns()
  if is_fzf_picker then
    fzflua.diagnostics_workspace({ severity_limit = vim.diagnostic.severity.WARN, sort = true })
  else
    Snacks.picker.diagnostics({
      sort = { fields = { "severity", "is_current", "is_cwd", "file", "lnum" } },
      severity = { min = vim.diagnostic.severity.WARN },
    })
  end
end

-- 仅查找错误 (Errors)
local function diagnostics_workspace_errors()
  if is_fzf_picker then
    fzflua.diagnostics_workspace({ sort = true, severity_limit = vim.diagnostic.severity.ERROR })
  else
    Snacks.picker.diagnostics({
      sort = { fields = { "severity", "is_current", "is_cwd", "file", "lnum" } },
      severity = { min = vim.diagnostic.severity.ERROR },
    })
  end
end

-- ===========================================================================
-- 2. 快捷键设置 (Keymap Setup)
--    这些快捷键只有在 LSP 启动成功后才会生效
-- ===========================================================================
M.keymap_setup = function()
  -- 基础 LSP 功能
  vim.keymap.set("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "LspInfo" }) -- 查看 LSP 状态

  -- 悬停查看文档 (Hover)
  vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover({ border = "single" }) -- 使用单线边框
  end, { desc = "Hover", silent = true, noremap = true })

  -- 函数签名帮助 (Signature Help)
  vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, { desc = "Signature Help" })
  vim.keymap.set("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" }) -- 插入模式下也可以用 Ctrl+k

  -- 代码操作 (Code Action) - 类似 VSCode 的 "快速修复"
  vim.keymap.set({ "n", "v", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

  -- CodeLens (代码透镜) 操作
  vim.keymap.set({ "n", "v" }, "<leader>cc", vim.lsp.codelens.run, { desc = "Codelens" })
  vim.keymap.set(
    { "n", "v" },
    "<leader>cC",
    vim.lsp.codelens.refresh,
    { desc = "Codelens Refresh" }
  )

  -- 重命名 (Rename)
  vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" }) -- 原生重命名
  vim.keymap.set("n", "<leader>cR", Snacks.rename.rename_file, { desc = "Snacks Rename" }) -- Snacks 文件重命名(连带更新引用)

  -- 快速跳转引用 (Snacks words)
  -- 类似于 vim-illuminate，按 ]] 跳转到该变量下一次出现的地方
  vim.keymap.set("n", "]]", function()
    Snacks.words.jump(vim.v.count1)
  end, { desc = "Next Reference" })
  vim.keymap.set("n", "[[", function()
    Snacks.words.jump(-vim.v.count1)
  end, { desc = "Prev Reference" })

  -- 诊断信息跳转 (]d, [d, ]e, [e)
  local diagnostic_goto = function(count, severity)
    local opts = { count = count, severity = severity and vim.diagnostic.severity[severity] or nil }
    return function()
      vim.diagnostic.jump(opts)
    end
  end

  vim.keymap.set("n", "]d", diagnostic_goto(1), { desc = "Next diagnostic" })
  vim.keymap.set("n", "[d", diagnostic_goto(-1), { desc = "Prev diagnostic" })
  vim.keymap.set("n", "]e", diagnostic_goto(1, "ERROR"), { desc = "Next error" }) -- 仅跳转错误
  vim.keymap.set("n", "[e", diagnostic_goto(-1, "ERROR"), { desc = "Prev error" })
  vim.keymap.set("n", "]w", diagnostic_goto(1, "WARN"), { desc = "Next warning" }) -- 仅跳转警告
  vim.keymap.set("n", "[w", diagnostic_goto(-1, "WARN"), { desc = "Prev warning" })

  -- 跳转定义/引用 (使用上面定义的 Picker 包装函数)
  vim.keymap.set("n", "gd", lsp_definitions, { desc = "Goto Definition", noremap = true })
  vim.keymap.set("n", "gD", lsp_declarations, { desc = "Goto Declaration", noremap = true })
  vim.keymap.set("n", "gr", lsp_references, { desc = "Goto References", noremap = true })
  vim.keymap.set("n", "gi", lsp_implementations, { desc = "Goto Implementation", noremap = true })
  vim.keymap.set("n", "gy", lsp_type_definitions, { desc = "Goto TypeDefs", noremap = true })
  vim.keymap.set("n", "gI", lsp_incoming_calls, { desc = "Incoming Calls", noremap = true }) -- 调用层级：谁调用了我
  vim.keymap.set("n", "gO", lsp_outgoing_calls, { desc = "Outgoing Calls", noremap = true }) -- 调用层级：我调用了谁
  vim.keymap.set("n", "<leader>ss", lsp_symbols, { desc = "Lsp symbols" })
  vim.keymap.set("n", "<leader>sS", lsp_workspace_symbols, { desc = "Workspace lsp symbols" })

  -- 打开诊断列表
  vim.keymap.set("n", "<leader>xx", diagnostics_buffer, { desc = "Diagnostics" })
  vim.keymap.set("n", "<leader>xX", diagnostics_workspace, { desc = "Workspace Diagnostics" })
  vim.keymap.set(
    "n",
    "<leader>xw",
    diagnostics_workspace_warns,
    { desc = "Workspace Diagnostics(Warns)" }
  )
  vim.keymap.set(
    "n",
    "<leader>xe",
    diagnostics_workspace_errors,
    { desc = "Workspace Diagnostics(Errors)" }
  )
end

-- ===========================================================================
-- 3. 方法能力设置 (Methods/Capabilities Setup)
--    根据 LSP 服务器支持的功能，开启特定的 Neovim 特性
-- ===========================================================================
M.methods_setup = function(client, bufnr)
  local Methods = vim.lsp.protocol.Methods

  -- [Neovim 0.12+] 关联编辑范围 (Linked Editing Range)
  -- 类似于 HTML 标签修改：改 <div> 自动改结尾的 </div>
  if
    client:supports_method(Methods.textDocument_linkedEditingRange)
    and vim.fn.has("nvim-0.12") == 1
  then
    vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
  end

  -- [Neovim 0.12+] 输入时格式化 (On Type Formatting)
  if
    client:supports_method(Methods.textDocument_onTypeFormatting) and vim.fn.has("nvim-0.12") == 1
  then
    vim.lsp.on_type_formatting.enable(true, { client_id = client.id })
  end

  -- [Neovim 0.12+] 文档颜色 (Document Color)
  -- 比如在 CSS 中显示颜色背景。注释提到你可能更倾向于用 nvim-highlight-colors 插件。
  if
    client:supports_method(Methods.textDocument_documentColor) and vim.fn.has("nvim-0.12") == 1
  then
    vim.lsp.document_color.enable(true, bufnr, { style = "background" })
  end

  -- 默认禁用内嵌提示 (Inlay Hints)，防止界面太乱，你可以在 snacks 配置里通过 <leader>uh 动态开启
  if client:supports_method(Methods.textDocument_inlayHints) then
    vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
  end

  -- 光标下引用高亮 (Document Highlight)
  -- 当光标停留在变量上时，高亮该变量在当前文件中的所有出现
  if client:supports_method(Methods.textDocument_documentHighlight) then
    local under_cursor_highlights_group =
      vim.api.nvim_create_augroup("xue/cursor_highlights", { clear = false })

    -- CursorHold: 光标停止移动一段时间后触发高亮
    vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
      group = under_cursor_highlights_group,
      desc = "Highlight references under the cursor",
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })

    -- CursorMoved: 光标移动后清除高亮
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
      group = under_cursor_highlights_group,
      desc = "Clear highlight references",
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end

  -- CodeLens (代码透镜) 支持
  -- 在函数上方显示 "Run Test" 或 "3 References" 等虚拟文本
  if client:supports_method(Methods.textDocument_codeLens) then
    if vim.g.codelens then
      vim.lsp.codelens.refresh({ bufnr = bufnr })
    end
    vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
      buffer = bufnr,
      callback = function()
        if vim.g.codelens then
          vim.lsp.codelens.refresh({ bufnr = bufnr })
        else
          vim.lsp.codelens.clear(nil, bufnr)
        end
      end,
    })
  end

  -- Eslint 专属修复逻辑
  -- 如果是 eslint 服务器，保存文件时自动运行 FixAll
  if client and client.name == "eslint" then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      group = vim.api.nvim_create_augroup("eslintFix", { clear = true }),
      callback = function()
        if vim.fn.exists(":LspEslintFixAll") > 0 then
          Snacks.notifier("EslintFixAll", "info") -- 弹出通知
          vim.cmd("LspEslintFixAll")
        end
      end,
    })
  end
end

-- ===========================================================================
-- 4. 挂载入口 (On Attach)
--    这是外部调用的主函数
-- ===========================================================================
M.on_attach = function(client, bufnr)
  M.keymap_setup() -- 设置快捷键
  M.methods_setup(client, bufnr) -- 设置功能特性
end

return M
