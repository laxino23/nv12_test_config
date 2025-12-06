local M = {}

function M.setup()
  vim.pack.add({
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/whoissethdaniel/mason-tool-installer.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/nvimdev/lspsaga.nvim" },
    { src = "https://github.com/stevearc/conform.nvim" },
    { src = "https://github.com/mfussenegger/nvim-lint" },
  })

  require("plugins.lsp.ui")
  require("plugins.lsp.keymaps")
  require("plugins.lsp.servers")
  require("plugins.lsp.formatting")
  require("plugins.lsp.mason")
  require("plugins.lsp.linting")
end

M.setup()

return M
