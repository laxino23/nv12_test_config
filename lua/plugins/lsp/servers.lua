-- =============================================================================
-- Capabilities Setup (CRUCIAL FOR UFO)
-- 能力配置 (UFO 必需) - 必须放在任何服务器配置之前！
-- =============================================================================
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Enable Folding Range capabilities for nvim-ufo
-- 启用 nvim-ufo 所需的折叠范围能力
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

-- =============================================================================
-- Specific Server Configurations
-- 特定服务器配置
-- =============================================================================

-- [Lua] lua_ls
vim.lsp.config("lua_ls", {
  capabilities = capabilities,
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
    })
  end,
  settings = {
    Lua = {
      codeLens = { enable = true },
      hint = { enable = true, semicolon = "Disable" },
      diagnostics = { globals = { "vim", "Snacks", "MiniIcons" } },
    },
  },
})

-- [Python] pyright
vim.lsp.config("pyright", {
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- [Rust] rust_analyzer
vim.lsp.config("rust_analyzer", {
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      diagnostics = { enable = true },
      lens = { enable = true },
      checkOnSave = { command = "clippy" },
    },
  },
})

-- [C/C++] clangd
vim.lsp.config("clangd", {
  capabilities = capabilities,
  cmd = { "clangd", "--offset-encoding=utf-16" },
})

-- Default config for all other servers
-- 所有其他服务器的默认配置
vim.lsp.config("*", {
  capabilities = capabilities,
})
