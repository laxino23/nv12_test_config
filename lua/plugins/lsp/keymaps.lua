-- =============================================================================
-- Helper Functions / 辅助函数
-- =============================================================================

-- Jump to the start of the current function context
-- 跳转到当前函数的开头
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

-- Jump to the end of the current function context
-- 跳转到当前函数的结尾
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
-- LspAttach Keymaps / LSP 挂载按键映射
-- =============================================================================
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(event)
    local function map(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    -- Lspsaga maps
    map("K", "<cmd>Lspsaga hover_doc<CR>", "Hover Documentation")
    map("gr", "<cmd>Lspsaga finder<CR>", "Finder (Refs/Def)")
    map("<leader>ca", "<cmd>Lspsaga code_action<CR>", "Code Action")
    map("<leader>rn", "<cmd>Lspsaga rename<CR>", "Rename")

    -- Diagnostic maps
    map("]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", "Next Diagnostic")
    map("[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Prev Diagnostic")
    map("]E", function()
      require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, "Next Error")
    map("[E", function()
      require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, "Prev Error")

    -- Diagnostic Lists
    map("<leader>ldl", "<cmd>Lspsaga show_line_diagnostics<CR>", "Show Line Diagnostics")
    map("<leader>ldw", "<cmd>Lspsaga show_cursor_dagnostics<CR>", "Show Cursor Diagnostics")
    map("<leader>ldb", "<cmd>Lspsaga show_buf_diagnostics<CR>", "Show Buffer Diagnostics")
    map("<leader>ldd", "<cmd>Lspsaga show_workspace_diagnostics<CR>", "Show Workspace Diagnostics")

    -- Goto Definition (Snacks.nvim integration)
    map("gtd", function()
      if package.loaded["snacks"] then
        require("snacks").picker.lsp_definitions()
      else
        vim.lsp.buf.definition()
      end
    end, "Goto Definition")

    -- Custom Function Jumps
    map("[f", jump_to_current_function_start, "Jump to function start")
    map("]f", jump_to_current_function_end, "Jump to function end")

    -- Inlay Hints Toggle
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
      end, "Toggle Inlay Hints")
    end
  end,
})
