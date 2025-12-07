local ui = require("plugins.heirline.ui")
local colors = ui.colors
local mode_colors = ui.mode_colors
local icons = ui.icons
local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

-- Vi 模式组件（双字母显示，如 NO, VI, VL, IN）
local ViMode = {
  init = function(self)
    self.mode = vim.fn.mode(1)
  end,
  static = {
    mode_names = {
      n = "NO", -- Normal
      no = "NO", -- Operator pending
      nov = "NO",
      noV = "NO",
      ["no\22"] = "NO",
      niI = "NI",
      niR = "NR",
      niV = "NV",
      nt = "NT",
      v = "VI", -- Visual
      vs = "VI",
      V = "VL", -- Visual Line
      Vs = "VL",
      ["\22"] = "VB", -- Visual Block (Ctrl-V)
      ["\22s"] = "VB",
      s = "SE", -- Select
      S = "SL", -- Select Line
      ["\19"] = "SB", -- Select Block (Ctrl-S)
      i = "IN", -- Insert
      ic = "IN",
      ix = "IN",
      R = "RE", -- Replace
      Rc = "RC",
      Rx = "RX",
      Rv = "RV",
      Rvc = "RV",
      Rvx = "RV",
      c = "CO", -- Command
      cv = "EX",
      r = "PR", -- Prompt
      rm = "MO",
      ["r?"] = "CO",
      ["!"] = "SH", -- Shell
      t = "TE", -- Terminal
    },
  },
  provider = function(self)
    return " " .. (self.mode_names[self.mode] or "??") .. " "
  end,
  hl = function(self)
    local mode = self.mode:sub(1, 1)
    return { fg = colors.bg, bg = mode_colors[mode] or colors.mode_n, bold = true }
  end,
  update = {
    "ModeChanged",
    pattern = "*:*",
    callback = vim.schedule_wrap(function()
      vim.cmd("redrawstatus")
    end),
  },
}

-- 使用 utils.surround 包装 ViMode（动态颜色）
ViMode = utils.surround({ icons.left_sep, icons.right_sep }, function(self)
  local mode = vim.fn.mode(1):sub(1, 1)
  return mode_colors[mode] or colors.mode_n
end, ViMode)

-- Git 组件（只在 git repo 中显示）
local Git = {
  condition = conditions.is_git_repo,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes = (self.status_dict.added or 0) > 0
      or (self.status_dict.changed or 0) > 0
      or (self.status_dict.removed or 0) > 0
  end,
  hl = { fg = colors.fg, bg = colors.section_bg },
  {
    provider = function(self)
      return " " .. icons.git .. (self.status_dict.head or "")
    end,
  },
  {
    condition = function(self)
      return self.has_changes
    end,
    provider = function(self)
      local added = self.status_dict.added or 0
      local changed = self.status_dict.changed or 0
      local removed = self.status_dict.removed or 0

      local result = ""
      if added > 0 then
        result = result .. " +" .. added
      end
      if changed > 0 then
        result = result .. " ~" .. changed
      end
      if removed > 0 then
        result = result .. " -" .. removed
      end

      return result .. " "
    end,
  },
  {
    condition = function(self)
      return not self.has_changes
    end,
    provider = " ",
  },
}
Git = utils.surround({ icons.left_sep, icons.right_sep }, colors.section_bg, Git)

-- 文件路径（相对于 cwd，删除 flexible 部分避免重复）
local FilePath = {
  init = function(self)
    self.filename = vim.fn.expand("%:.")
    if self.filename == "" then
      self.filename = "[No Name]"
    end
  end,
  provider = function(self)
    return " " .. icons.file .. self.filename .. " "
  end,
  hl = { fg = colors.fg, bg = colors.section_bg },
}
FilePath = utils.surround({ icons.left_sep, icons.right_sep }, colors.section_bg, FilePath)

-- 诊断信息（只在有诊断时显示）
local Diagnostics = {
  condition = conditions.has_diagnostics,
  static = {
    error_icon = icons.error,
    warn_icon = icons.warn,
    info_icon = icons.info,
    hint_icon = icons.hint,
  },
  init = function(self)
    self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  end,
  update = { "DiagnosticChanged", "BufEnter" },
  hl = { bg = colors.section_bg },
  {
    provider = " ",
    hl = { bg = colors.section_bg },
  },
  {
    condition = function(self)
      return self.errors > 0
    end,
    provider = function(self)
      return self.error_icon .. self.errors .. " "
    end,
    hl = { fg = colors.diag_error, bg = colors.section_bg },
  },
  {
    condition = function(self)
      return self.warnings > 0
    end,
    provider = function(self)
      return self.warn_icon .. self.warnings .. " "
    end,
    hl = { fg = colors.diag_warn, bg = colors.section_bg },
  },
  {
    condition = function(self)
      return self.info > 0
    end,
    provider = function(self)
      return self.info_icon .. self.info .. " "
    end,
    hl = { fg = colors.diag_info, bg = colors.section_bg },
  },
  {
    condition = function(self)
      return self.hints > 0
    end,
    provider = function(self)
      return self.hint_icon .. self.hints .. " "
    end,
    hl = { fg = colors.diag_hint, bg = colors.section_bg },
  },
}
Diagnostics = utils.surround({ icons.left_sep, icons.right_sep }, colors.section_bg, Diagnostics)

-- LSP 信息（只在 LSP attached 时显示）
local LSP = {
  condition = conditions.lsp_attached,
  update = { "LspAttach", "LspDetach", "BufEnter" },
  provider = function()
    local progress = require("lsp-progress").progress()
    return " " .. icons.lsp .. (progress ~= "" and progress or "LSP") .. " "
  end,
  hl = { fg = colors.fg, bg = colors.section_bg },
}
LSP = utils.surround({ icons.left_sep, icons.right_sep }, colors.section_bg, LSP)

-- DAP 组件（只在调试时显示）
local DAP = {
  condition = function()
    local ok, dap = pcall(require, "dap")
    return ok and dap.session() ~= nil
  end,
  provider = function()
    return " " .. icons.dap .. "Debugging "
  end,
  hl = { fg = colors.dap, bg = colors.section_bg, bold = true },
  update = { "User", pattern = "DapStarted" },
}
DAP = utils.surround({ icons.left_sep, icons.right_sep }, colors.section_bg, DAP)

-- 文件类型（只在有 filetype 时显示）
local FileType = {
  condition = function()
    return vim.bo.filetype ~= ""
  end,
  provider = function()
    return " " .. icons.ft .. string.upper(vim.bo.filetype) .. " "
  end,
  hl = { fg = colors.fg, bg = colors.section_bg },
}
FileType = utils.surround({ icons.left_sep, icons.right_sep }, colors.section_bg, FileType)

-- 行号/列号和百分比
local Nav = {
  provider = function()
    local line = vim.fn.line(".")
    local total = vim.fn.line("$")
    local col = vim.fn.virtcol(".")
    local percent = math.floor((line / total) * 100)
    return string.format(" %d:%d  %d%%%% ", line, col, percent)
  end,
  hl = { fg = colors.fg, bg = colors.section_bg },
  update = { "CursorMoved", "CursorMovedI", "BufEnter" },
}
Nav = utils.surround({ icons.left_sep, icons.right_sep }, colors.section_bg, Nav)

-- 填充和间距
local Align = { provider = "%=", hl = { bg = colors.bg } }
local Space = { provider = " ", hl = { bg = colors.bg } }

return {
  ViMode = ViMode,
  Git = Git,
  FilePath = FilePath,
  Diagnostics = Diagnostics,
  LSP = LSP,
  DAP = DAP,
  FileType = FileType,
  Nav = Nav,
  Align = Align,
  Space = Space,
}
