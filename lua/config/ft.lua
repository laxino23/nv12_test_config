-- Filetype-specific configurations

---@class FileTypeConfig
---@field indent number|nil Tab/indent width
---@field expandtab boolean|nil Use spaces instead of tabs
---@field colorcolumn string|nil Column guide (e.g., "80", "80,120")
---@field commentstring string|nil Comment format (e.g., "# %s", "// %s")
---@field textwidth number|nil Max line width for formatting
---@field wrap boolean|nil Enable line wrapping
---@field spell boolean|nil Enable spell checking
---@field conceallevel number|nil Conceal level (0-3)

---@type table<string, FileTypeConfig>
local M = {
  -- ============================================================================
  -- Web Development
  -- ============================================================================
  javascript = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80,100",
    commentstring = "// %s",
  },

  typescript = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80,100",
    commentstring = "// %s",
  },

  javascriptreact = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80,100",
    commentstring = "// %s",
  },

  typescriptreact = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80,100",
    commentstring = "// %s",
  },

  html = {
    indent = 2,
    expandtab = true,
    colorcolumn = "120",
    commentstring = "<!-- %s -->",
  },

  css = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "/* %s */",
  },

  scss = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "// %s",
  },

  -- ============================================================================
  -- Systems Programming
  -- ============================================================================
  c = {
    indent = 4,
    expandtab = true,
    colorcolumn = "80,120",
    commentstring = "// %s",
  },

  cpp = {
    indent = 4,
    expandtab = true,
    colorcolumn = "80,120",
    commentstring = "// %s",
  },

  rust = {
    indent = 4,
    expandtab = true,
    colorcolumn = "100",
    commentstring = "// %s",
  },

  go = {
    indent = 4,
    expandtab = false, -- Go uses tabs
    colorcolumn = "80,120",
    commentstring = "// %s",
  },

  zig = {
    indent = 4,
    expandtab = true,
    colorcolumn = "100",
    commentstring = "// %s",
  },

  -- ============================================================================
  -- Scripting Languages
  -- ============================================================================
  python = {
    indent = 4,
    expandtab = true,
    colorcolumn = "79,88,120", -- PEP 8 (79), Black (88)
    commentstring = "# %s",
    textwidth = 88,
  },

  lua = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80,120",
    commentstring = "-- %s",
  },

  ruby = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80,120",
    commentstring = "# %s",
  },

  perl = {
    indent = 4,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "# %s",
  },

  php = {
    indent = 4,
    expandtab = true,
    colorcolumn = "120",
    commentstring = "// %s",
  },

  -- ============================================================================
  -- JVM Languages
  -- ============================================================================
  java = {
    indent = 4,
    expandtab = true,
    colorcolumn = "100,120",
    commentstring = "// %s",
  },

  kotlin = {
    indent = 4,
    expandtab = true,
    colorcolumn = "100,120",
    commentstring = "// %s",
  },

  scala = {
    indent = 2,
    expandtab = true,
    colorcolumn = "100,120",
    commentstring = "// %s",
  },

  -- ============================================================================
  -- Functional Languages
  -- ============================================================================
  haskell = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "-- %s",
  },

  elixir = {
    indent = 2,
    expandtab = true,
    colorcolumn = "98,120",
    commentstring = "# %s",
  },

  erlang = {
    indent = 4,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "% %s",
  },

  -- ============================================================================
  -- Markup & Data Languages
  -- ============================================================================
  markdown = {
    indent = 2,
    expandtab = true,
    colorcolumn = "",
    commentstring = "<!-- %s -->",
    wrap = true,
    spell = true,
    conceallevel = 2,
  },

  json = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "",
  },

  yaml = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "# %s",
  },

  toml = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "# %s",
  },

  xml = {
    indent = 2,
    expandtab = true,
    colorcolumn = "120",
    commentstring = "<!-- %s -->",
  },

  -- ============================================================================
  -- Shell & Config
  -- ============================================================================
  sh = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "# %s",
  },

  bash = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "# %s",
  },

  zsh = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "# %s",
  },

  vim = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80",
    commentstring = '" %s',
  },

  -- ============================================================================
  -- Documentation
  -- ============================================================================
  tex = {
    indent = 2,
    expandtab = true,
    colorcolumn = "80",
    commentstring = "% %s",
    wrap = true,
    spell = true,
  },

  rst = {
    indent = 3,
    expandtab = true,
    colorcolumn = "80",
    commentstring = ".. %s",
    wrap = true,
    spell = true,
  },

  -- ============================================================================
  -- Makefiles (special case - must use tabs)
  -- ============================================================================
  make = {
    indent = 4,
    expandtab = false, -- Makefiles require tabs
    colorcolumn = "80",
    commentstring = "# %s",
  },
}

return M
