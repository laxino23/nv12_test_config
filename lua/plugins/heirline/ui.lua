-- 颜色定义（动态从当前颜色方案获取，支持渐变）
local colors = {
  bg = "#1a1b26", -- 背景
  fg = "#a9b1d6", -- 前景
  section_bg = "#24283b",
  mode_n = "#9ece6a", -- Normal 模式绿色
  mode_i = "#7aa2f7", -- Insert 蓝色
  mode_v = "#bb9af7", -- Visual 紫色
  mode_r = "#f7768e", -- Replace 红色
  mode_c = "#e0af68", -- Command 橙色
  mode_t = "#73daca", -- Terminal 青色
  git = "#e0af68", -- Git 橙色
  diag_error = "#f7768e", -- 错误红色
  diag_warn = "#e0af68", -- 警告橙色
  diag_info = "#7aa2f7", -- 信息蓝色
  diag_hint = "#bb9af7", -- 提示紫色
  lsp = "#73daca", -- LSP 绿松石
  dap = "#f7768e", -- DAP 红色
  ft = "#9ece6a", -- 文件类型绿色
  nav = "#a9b1d6", -- 导航灰色
}
-- 模式颜色映射（使用第一个字母作为键）
local mode_colors = {
  n = colors.mode_n, -- Normal
  i = colors.mode_i, -- Insert
  v = colors.mode_v, -- Visual
  V = colors.mode_v, -- Visual Line
  ["\22"] = colors.mode_v, -- Visual Block (Ctrl-V)
  s = colors.mode_v, -- Select
  S = colors.mode_v, -- Select Line
  ["\19"] = colors.mode_v, -- Select Block (Ctrl-S)
  R = colors.mode_r, -- Replace
  r = colors.mode_r, -- Prompt/Replace
  c = colors.mode_c, -- Command
  ["!"] = colors.mode_c, -- Shell
  t = colors.mode_t, -- Terminal
}
-- Nerd Fonts 图标和分隔符
local icons = {
  mode = " ", -- Vi 模式
  git = " ", -- Git 分支
  file = "󰈙 ", -- 文件
  error = "󰅚 ", -- 诊断错误
  warn = "󰀪 ", -- 警告
  info = "󰋽 ", -- 信息
  hint = "󰌶 ", -- 提示
  lsp = " ", -- LSP
  dap = " ", -- DAP
  ft = " ", -- 文件类型
  left_sep = "", -- 左侧分隔
  right_sep = "", -- 右侧分隔
}

return {
  colors = colors,
  mode_colors = mode_colors, -- 新增
  icons = icons,
}
