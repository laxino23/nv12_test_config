local conditions = require("heirline.conditions")
local component = require("plugins.heirline.component")
local ui = require("plugins.heirline.ui")
local colors = ui.colors

-- 活跃状态栏
local DefaultStatusline = {
  component.ViMode,
  component.Space,
  component.Git,
  component.Space,
  component.FilePath,
  component.Align,
  component.Diagnostics,
  component.Align,
  component.DAP,
  component.Space,
  component.LSP,
  component.Space,
  component.FileType,
  component.Space,
  component.Nav,
}

-- 非活跃状态栏（简化版）
local InactiveStatusline = {
  condition = conditions.is_not_active,
  component.FilePath,
  component.Align,
  component.Nav,
}

-- 特殊缓冲区状态栏（例如 Help、Terminal）
local SpecialStatusline = {
  condition = function()
    return conditions.buffer_matches({
      buftype = { "nofile", "prompt", "help", "quickfix" },
      filetype = { "^git.*", "fugitive" },
    })
  end,
  component.FileType,
  component.Align,
  component.Nav,
}

-- 终端状态栏
local TerminalStatusline = {
  condition = function()
    return conditions.buffer_matches({ buftype = { "terminal" } })
  end,
  hl = { bg = colors.bg },
  { provider = "TERMINAL", hl = { fg = colors.mode_n, bold = true } },
  component.Align,
  component.Nav,
}

-- 组合所有
local StatusLines = {
  hl = function()
    if conditions.is_active() then
      return { fg = colors.fg, bg = colors.bg }
    else
      return { fg = colors.fg, bg = colors.bg }
    end
  end,
  fallthrough = false,
  SpecialStatusline,
  TerminalStatusline,
  InactiveStatusline,
  DefaultStatusline,
}

return StatusLines
