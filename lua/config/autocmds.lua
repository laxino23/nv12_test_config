-- guide lines for cursorline
local function set_transparent_guides()
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE", underline = true, bold = true })

  vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE", fg = "#ff9e64", bold = true })

  vim.api.nvim_set_hl(0, "ColorColumn", { bg = "NONE", fg = "#ff0000" })
end

set_transparent_guides()

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_transparent_guides,
})

-- Set scrolloff to 25% of window height
vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
  callback = function()
    local height = vim.api.nvim_win_get_height(0)
    vim.wo.scrolloff = math.floor(height * 0.25)
  end,
})

-- Set initial value
vim.o.scrolloff = math.floor(vim.o.lines * 0.25)

-- auto detect the file type
local ft_configs = require("config.ft")

local function apply_ft_config(args)
  local ft = args.match
  local config = ft_configs[ft]

  if config then
    -- Apply indentation
    if config.indent then
      vim.opt_local.shiftwidth = config.indent
      vim.opt_local.tabstop = config.indent
      vim.opt_local.softtabstop = config.indent
    end

    -- Apply tab expansion
    if config.expandtab ~= nil then
      vim.opt_local.expandtab = config.expandtab
    end

    -- Apply comment string (Fixes your commenting issue)
    if config.commentstring then
      vim.opt_local.commentstring = config.commentstring
    end

    -- Apply other options
    if config.colorcolumn then
      vim.opt_local.colorcolumn = config.colorcolumn
    end
    if config.textwidth then
      vim.opt_local.textwidth = config.textwidth
    end
    if config.wrap ~= nil then
      vim.opt_local.wrap = config.wrap
    end
    if config.spell ~= nil then
      vim.opt_local.spell = config.spell
    end
  end
end

-- vim.api.nvim_create_autocmd("FileType", {
--   group = vim.api.nvim_create_augroup("CustomFileTypeSettings", { clear = true }),
--   pattern = "*",
--   callback = apply_ft_config,
-- })
--
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*",
--   callback = function(args)
--     require("conform").format({ bufnr = args.buf })
--   end,
-- })
