-- =============================================================================
-- guide lines for cursorline
-- =============================================================================
local function set_transparent_guides()
  local pmenu_bg = vim.api.nvim_get_hl(0, { name = "Pmenu" }).bg
  local bg_color = pmenu_bg and string.format("#%06x", pmenu_bg) or "#2c3248"
  local ul_color = "#ffff00"
  vim.api.nvim_set_hl(
    0,
    "CursorLine",
    { bg = bg_color, underdouble = true, bold = false, sp = ul_color }
  )
  vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE", fg = "#ff9e64", bold = false })
  vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#1f1f1f", fg = "NONE" })
end
set_transparent_guides()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_transparent_guides,
})

-- =============================================================================
-- Set scrolloff to 25% of window height
-- =============================================================================
vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
  callback = function()
    local height = vim.api.nvim_win_get_height(0)
    vim.wo.scrolloff = math.floor(height * 0.25)
  end,
})

-- =============================================================================
-- Set initial value
-- =============================================================================
vim.o.scrolloff = math.floor(vim.o.lines * 0.25)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "javascript", "typescript", "react", "json", "html", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "c", "cpp", "rust" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})
-- Disable auto-comment on o and O
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "o" })
  end,
})

-- =============================================================================
-- Save buffer fold and cursor position
-- =============================================================================

-- Create an augroup to prevent duplicate definitions
local view_group = vim.api.nvim_create_augroup("AutoView", { clear = true })

-- Save the view when leaving the file window
vim.api.nvim_create_autocmd("BufWinLeave", {
  group = view_group,
  pattern = "*", -- 匹配所有文件 (Match all files)
  callback = function()
    -- Only save for normal files, ignore special buffers like NvimTree
    if vim.bo.buftype == "" then
      vim.cmd("mkview")
    end
  end,
})

-- Load the view when entering the file window
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = view_group,
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "" then
      -- Use silent! to avoid errors if the file has no saved view yet
      vim.defer_fn(function()
        vim.cmd("silent! loadview")
      end, 100)
    end
  end,
})
