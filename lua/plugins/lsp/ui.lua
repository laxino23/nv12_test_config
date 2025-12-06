-- Lspsaga Setup
-- Lspsaga 设置
require("lspsaga").setup({
  symbol_in_winbar = { enable = true, separator = " › " },
  lightbulb = { enable = true, sign = true, virtual_text = false },
  ui = { border = "rounded", code_action = "💡" },
  scroll_preview = { scroll_down = "<C-f>", scroll_up = "<C-b>" },
  diagnostic = {
    show_code_action = true,
    show_source = true,
    jump_num_shortcut = true,
    max_width = 0.7,
    max_height = 0.6,
    text_hl_follow = true,
    border_follow = true,
    extend_relatedInformation = false,
    show_layout = "float",
    diagnostic_only_current = false,
    keys = {
      exec_action = "o",
      quit = "q",
      toggle_or_jump = "<CR>",
      quit_in_show = { "q", "<ESC>" },
    },
  },
})
